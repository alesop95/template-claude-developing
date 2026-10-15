#!/usr/bin/env bash
# Allestimento di Veeam Agent for Linux su una macchina Linux.
# Attua le fasi da 0 a 5 della guida del pacchetto veeam-linux (GUIDA.md).
#
# Lo script raccomanda e non decide: "controlli" stampa i fatti della macchina
# e un blocco di valori proposto, che va riletto e corretto prima di proseguire.
# Le tre decisioni che cambiano da una macchina all'altra (variante del
# pacchetto, percorsi inclusi, collocazione del deposito) restano di chi esegue.
#
# Uso:
#   veeam-allestisci.sh controlli
#   veeam-allestisci.sh --valori ./valori.sh installa
#   veeam-allestisci.sh --valori ./valori.sh configura
#   veeam-allestisci.sh --valori ./valori.sh esegui [--pieno] [--attendi]
#   veeam-allestisci.sh --valori ./valori.sh stato

set -uo pipefail

VALORI=""
SOTTOCOMANDO=""
PIENO=0
ATTENDI=0

msg()    { printf '%s\n' "$*"; }
titolo() { printf '\n== %s ==\n' "$*"; }
errore() { printf 'ERRORE: %s\n' "$*" >&2; exit 1; }
avviso() { printf 'ATTENZIONE: %s\n' "$*" >&2; }

uso() {
  sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
}

while [ $# -gt 0 ]; do
  case "$1" in
    --valori)  VALORI="${2:-}"; shift 2 ;;
    --pieno)   PIENO=1; shift ;;
    --attendi) ATTENDI=1; shift ;;
    -h|--help) uso ;;
    -*)        errore "opzione sconosciuta: $1" ;;
    *)         SOTTOCOMANDO="$1"; shift ;;
  esac
done

[ -n "$SOTTOCOMANDO" ] || uso

# --- Privilegi --------------------------------------------------------------
# veeamconfig e' un collegamento a /usr/sbin/veeamworker, -rwxr-x--- root:veeam:
# gira da root oppure da una sessione che porta il gruppo veeam. L'appartenenza
# al gruppo si legge al login, quindi la sessione da cui si installa non ce l'ha.
vc() {
  if [ "$(id -u)" -eq 0 ] || id -nG | tr ' ' '\n' | grep -qx veeam; then
    veeamconfig "$@"
  else
    sudo veeamconfig "$@"
  fi
}

carica_valori() {
  [ -n "$VALORI" ] || errore "serve --valori FILE per il sottocomando '$SOTTOCOMANDO' (modello: valori.example.sh)"
  [ -f "$VALORI" ] || errore "file dei valori non trovato: $VALORI"
  # shellcheck disable=SC1090
  . "$VALORI"
  for v in PACCHETTO LIVELLO VERSIONE_REPO DEPOSITO NOME_DEPOSITO NOME_LAVORO PUNTI; do
    eval "valore=\${$v:-}"
    [ -n "$valore" ] || errore "il file dei valori non definisce $v"
  done
  if [ "$LIVELLO" = "fileLevel" ] && [ -z "${INCLUDI:-}" ]; then
    errore "LIVELLO e' fileLevel ma INCLUDI e' vuoto: ogni punto di innesto da salvare va nominato"
  fi
}

# --- Fase 0: controlli ------------------------------------------------------
cmd_controlli() {
  titolo "Macchina"
  msg "host:    $(hostname)"
  msg "sistema: $( . /etc/os-release 2>/dev/null; printf '%s' "${PRETTY_NAME:-sconosciuto}" )"
  msg "kernel:  $(uname -r)"
  msg "utente:  $(id -un)  gruppi: $(id -nG)"

  titolo "Volumi"
  lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT | grep -v '^loop'

  local lvm="no"
  if lsblk -rno TYPE 2>/dev/null | grep -qx lvm; then lvm="si"; fi
  msg ""
  msg "strato LVM presente: $lvm"

  titolo "Filesystem montati"
  df -hT -x tmpfs -x devtmpfs -x squashfs -x efivarfs

  titolo "Presupposti del modulo del kernel"
  msg "header per il kernel in uso: $(dpkg -l "linux-headers-$(uname -r)" 2>/dev/null | grep -c '^ii')"
  msg "dkms: $(command -v dkms >/dev/null && echo presente || echo assente)"

  titolo "Veeam gia' installato"
  if dpkg -l 2>/dev/null | grep -E '^ii +(veeam|veeam-nosnap|veeamsnap|blksnap) ' ; then
    avviso "l'agente risulta gia' installato: la fase 1 va saltata, e la configurazione va riverificata con i comandi del programma (voce E della guida)"
  else
    msg "nessun pacchetto veeam installato"
  fi

  # --- Raccomandazione ------------------------------------------------------
  local pacchetto livello nota
  if [ "$lvm" = "si" ]; then
    pacchetto="veeam-nosnap"; livello="volumeLevel"
    nota="i volumi sono LVM, quindi la variante senza modulo prende l'istantanea tramite LVM e il livello di volume e' disponibile senza dipendere dal kernel."
  else
    pacchetto="veeam-nosnap"; livello="fileLevel"
    nota="le partizioni sono semplici, quindi senza il modulo del kernel il livello di volume non e' possibile. Il modulo e' software di terze parti che insegue il kernel e su una distribuzione recente puo' non compilare: se serve l'immagine avviabile, o si prova il pacchetto 'veeam' accettando quel rischio, o la si prende a macchina spenta con Clonezilla."
  fi

  titolo "Raccomandazione"
  msg "$nota"
  msg ""
  msg "Variante consigliata: $pacchetto, livello $livello."
  msg "La tabella che decide sta nella sezione iniziale di GUIDA.md: questa e' una raccomandazione, non una scelta fatta."

  # --- Blocco di valori proposto -------------------------------------------
  local inclusi deposito avanzo base
  inclusi=$(findmnt -rno TARGET,SOURCE,FSTYPE 2>/dev/null \
    | awk '$2 ~ /^\/dev\// && $3 != "squashfs" && $3 != "vfat" {print $1}' \
    | sort -u | paste -sd, -)
  [ -n "$inclusi" ] || inclusi="/"

  # Deposito proposto sul filesystem incluso con piu' spazio libero.
  base=$(df -P -x tmpfs -x devtmpfs -x squashfs 2>/dev/null \
    | awk 'NR>1 {print $4, $6}' | sort -rn | head -1 | awk '{print $2}')
  [ -n "$base" ] || base="/"
  avanzo=$(df -h "$base" 2>/dev/null | awk 'NR>1 {print $4}')
  if [ "$base" = "/" ]; then deposito="/veeam-repo"; else deposito="$base/veeam-repo"; fi

  titolo "Blocco di valori proposto (da rileggere e correggere)"
  cat <<BLOCCO
PACCHETTO="$pacchetto"
LIVELLO="$livello"
VERSIONE_REPO="1.0.11"
DEPOSITO="$deposito"
NOME_DEPOSITO="repo-locale"
NOME_LAVORO="backup-$(hostname)"
INCLUDI="$inclusi"
ESCLUDI="$deposito,/proc,/sys,/dev,/run,/tmp,/snap,/mnt,/media"
PUNTI="2"
CAMPIONI="/etc/fstab,/etc/hostname"
ALBERO_CONTEGGIO="\$HOME"
DESTINAZIONE_ESTERNA=""
BLOCCO

  msg ""
  msg "Il deposito proposto sta su $base, che dichiara $avanzo liberi ed e' incluso nel backup: per questo compare anche in ESCLUDI."
  msg "VERSIONE_REPO non e' misurata qui: e' il solo valore che invecchia da solo e va verificato sul sito del produttore."
}

# --- Fase 1: installare -----------------------------------------------------
cmd_installa() {
  carica_valori
  local url="https://repository.veeam.com/backup/linux/agent/dpkg/debian/public/pool/veeam/v/veeam-release-deb/veeam-release-deb_${VERSIONE_REPO}_amd64.deb"

  titolo "Repository di Veeam"
  curl -sSL -o /tmp/veeam-release-deb.deb "$url" || errore "scaricamento del pacchetto di repository fallito: $url"
  sudo dpkg -i /tmp/veeam-release-deb.deb || errore "installazione del pacchetto di repository fallita"
  sudo apt update || errore "apt update fallito"

  titolo "Agente ($PACCHETTO)"
  if ! sudo apt install -y "$PACCHETTO"; then
    avviso "installazione fallita. Se si tratta della variante con modulo, il registro di compilazione sta in /var/lib/dkms/<modulo>/<versione>/build/make.log: la voce D della guida dice come distinguere un ambiente incompleto da un modulo scritto per un kernel precedente."
    exit 1
  fi

  titolo "Servizio"
  systemctl is-active veeamservice || avviso "veeamservice non risulta attivo"

  titolo "Contratti (fase 2)"
  msg "Il comando che segue chiede di accettare due contratti e attende 'yes' per ciascuno."
  msg "Non ha redirezione, di proposito: con l'uscita rediretta la domanda finisce nel file e il terminale sembra bloccato (voce A della guida)."
  vc repository list

  msg ""
  msg "L'installazione ha aggiunto l'utente al gruppo veeam, ma un processo riceve i propri gruppi al login: questa sessione non lo porta."
  msg "Aprirne una nuova fa sparire la necessita' di sudo per tutti i comandi successivi."
}

# --- Fasi 3 e 4: configurare ------------------------------------------------
cmd_configura() {
  carica_valori

  titolo "Contratti e stato corrente"
  # Senza cattura, cosi' una eventuale richiesta di accettazione resta visibile.
  vc repository list || errore "veeamconfig non risponde: se il messaggio e' 'Permission denied', vale la voce B della guida"

  local depositi lavori
  depositi=$(vc repository list 2>/dev/null) || errore "lettura dei depositi fallita"
  lavori=$(vc job list 2>/dev/null)          || errore "lettura dei lavori fallita"

  titolo "Fase 3, deposito"
  if printf '%s\n' "$depositi" | awk 'NR>1 {print $1}' | grep -Fxq "$NOME_DEPOSITO"; then
    msg "il deposito '$NOME_DEPOSITO' risulta gia' registrato: nessuna azione"
  else
    vc repository create --name "$NOME_DEPOSITO" --location "$DEPOSITO" --type local \
      || errore "creazione del deposito fallita"
    msg "creato."
  fi
  vc repository list

  titolo "Fase 4, lavoro"
  if printf '%s\n' "$lavori" | awk 'NR>1 {print $1}' | grep -Fxq "$NOME_LAVORO"; then
    msg "il lavoro '$NOME_LAVORO' risulta gia' registrato: nessuna azione"
  elif [ "$LIVELLO" = "volumeLevel" ]; then
    vc job create volumeLevel --name "$NOME_LAVORO" --repoName "$NOME_DEPOSITO" \
       --backupAllSystem --maxPoints "$PUNTI" \
      || errore "creazione del lavoro fallita. Se il messaggio e' 'Item cannot be backed up without veeam snapshot kernel module', vale la voce C della guida: non c'e' nulla da correggere nella configurazione, va cambiata la variante o il livello"
    msg "creato."
  else
    vc job create fileLevel --name "$NOME_LAVORO" --repoName "$NOME_DEPOSITO" \
       --includeDirs "$INCLUDI" --excludeDirs "${ESCLUDI:-}" --nosnap --maxPoints "$PUNTI" \
      || errore "creazione del lavoro fallita"
    msg "creato."
  fi
  vc job list

  case ",${ESCLUDI:-}," in
    *",$DEPOSITO,"*) : ;;
    *) avviso "il deposito $DEPOSITO non compare in ESCLUDI: se sta dentro un percorso incluso, il lavoro copiera' se stesso (voce F della guida)" ;;
  esac
}

# --- Fase 5: eseguire -------------------------------------------------------
cmd_esegui() {
  carica_valori

  titolo "Avvio del lavoro"
  if [ "$PIENO" -eq 1 ]; then
    msg "con --activeFull: punto pieno e indipendente, che costa altrettanto spazio del primo e non eredita dipendenze"
    vc job start --name "$NOME_LAVORO" --activeFull || errore "avvio fallito"
  else
    msg "senza --activeFull: punto incrementale, che dipende dal pieno precedente e non si porta fuori da solo"
    vc job start --name "$NOME_LAVORO" || errore "avvio fallito"
  fi

  if [ "$ATTENDI" -eq 0 ]; then
    msg ""
    msg "Il lavoro prosegue in secondo piano. L'avanzamento si segue da qualunque sessione:"
    msg "  df -h '$DEPOSITO'"
    msg "  ps -eo etime,cmd | grep -E 'veeamjobman|veeamagent' | grep -v grep"
    msg "A corsa finita l'esito va letto: 'veeamconfig session list', perche' un lavoro che finisce non e' un lavoro che riesce."
    return 0
  fi

  titolo "Attesa"
  while pgrep -x veeamjobman >/dev/null 2>&1 || pgrep -x veeamagent >/dev/null 2>&1; do
    printf '%s  %s\n' "$(date +%H:%M:%S)" "$(df -h "$DEPOSITO" | awk 'NR>1 {print $3" usati, "$4" liberi"}')"
    sleep 30
  done

  titolo "Esito dichiarato"
  msg "Lo stato puo' essere anche Warning o Failed: va letto, non dedotto dal fatto che la corsa sia finita."
  vc session list
}

cmd_stato() {
  carica_valori
  titolo "Depositi";  vc repository list
  titolo "Lavori";    vc job list
  titolo "Backup";    vc backup list
  titolo "Sessioni";  vc session list
  titolo "Spazio del deposito"; df -h "$DEPOSITO"
}

case "$SOTTOCOMANDO" in
  controlli) cmd_controlli ;;
  installa)  cmd_installa ;;
  configura) cmd_configura ;;
  esegui)    cmd_esegui ;;
  stato)     cmd_stato ;;
  *)         errore "sottocomando sconosciuto: $SOTTOCOMANDO" ;;
esac
