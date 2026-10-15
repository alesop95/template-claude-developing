#!/usr/bin/env bash
# Valori di allestimento Veeam per una macchina Linux.
#
# Si copia accanto agli script come "valori.sh", si adatta, e si carica con
# "source ./valori.sh" nella stessa shell da cui si lanciano gli script.
# Descrive una macchina reale (host, percorsi, destinazione): non va versionato
# in un repository pubblico, il posto giusto e' il livello privato del progetto.
#
# Il sottocomando "controlli" di veeam-allestisci.sh stampa un blocco gia'
# compilato con i fatti della macchina su cui gira: si parte da quello e lo si
# corregge, invece di indovinare i valori qui sotto.

# --- Variante del pacchetto -------------------------------------------------
# "veeam-nosnap" non porta il modulo del kernel: livello di volume solo su LVM.
# "veeam" porta il modulo via DKMS: livello di volume sempre, se il modulo
# compila contro il kernel in uso. La tabella che decide sta in GUIDA.md.
PACCHETTO="veeam-nosnap"

# Livello del lavoro: "fileLevel" oppure "volumeLevel".
LIVELLO="fileLevel"

# Versione del pacchetto di repository di Veeam. E' il solo valore di questa
# procedura che invecchia da solo: va verificato sul sito del produttore.
VERSIONE_REPO="1.0.11"

# --- Deposito ---------------------------------------------------------------
# Dove vengono scritti gli archivi. Un deposito sullo stesso disco che si salva
# protegge dall'errore e non dal guasto del disco: e' al piu' un luogo di
# transito, e la fase 7 della guida resta obbligatoria.
DEPOSITO="/home/veeam-repo"
NOME_DEPOSITO="repo-locale"

# --- Lavoro -----------------------------------------------------------------
NOME_LAVORO="backup-file-sistema"

# Punti di innesto da includere, separati da virgola. Ogni filesystem che si
# vuole salvare va nominato esplicitamente: --includeDirs non dichiara se
# l'attraversamento si fermi al confine del filesystem (voce G del
# troubleshooting). Usato solo quando LIVELLO e' "fileLevel".
INCLUDI="/,/home"

# Percorsi da escludere. Il deposito va escluso se si trova dentro un percorso
# incluso, altrimenti il lavoro copia se stesso (voce F del troubleshooting).
ESCLUDI="/home/veeam-repo,/proc,/sys,/dev,/run,/tmp,/snap,/mnt,/media"

# Numero di punti di ripristino conservati.
PUNTI="2"

# --- Verifica (fase 6) ------------------------------------------------------
# File confrontati per impronta fra sistema vivo e archivio montato: vanno
# scelti in modo da coprire tutti i filesystem inclusi e piu' ordini di
# grandezza. Separati da virgola, percorsi assoluti.
CAMPIONI="/etc/fstab,/etc/hostname"

# Albero su cui si confronta il conteggio dei file fra vivo e archivio.
ALBERO_CONTEGGIO="$HOME"

# --- Destinazione esterna (fase 7) ------------------------------------------
# Dove l'archivio viene portato fuori dalla macchina. Finche' resta vuoto, la
# fase 7 e' dichiarata non eseguita invece di essere data per fatta.
DESTINAZIONE_ESTERNA=""
