#!/usr/bin/env bash
scriptRoot="./reaper-keys/"

# keymapFile="keymaps/build/reaper-keys-linux.ReaperKeyMap"
keymapFile="keymaps/build/reaper-keys-windows.ReaperKeyMap"

rm -r keymaps/build/
mkdir keymaps/build/
mkdir keymaps/build/key_scripts

tmpScripts="scripts"
tmpKeys="keys"

function genScript() {
  local id desc file
  id="$1"
  desc="$2"
  file="$3"
  contextID="$4"
  printf "SCR 4 $contextID \"%s\" \"%s\" %s%s\n" "$id" "$desc" "$scriptRoot" "$file" >> "$tmpScripts"
}

function genKey() {
  local keyType keyCode target contextID
  keyType="$1"
  keyCode="$2"
  target="$3"
  contextID="$4"
  printf "KEY %s %s %s %s\n" "$keyType" "$keyCode" "$target" "$contextID"
}


function genContext() {
  local contextName
  tmpFile="$1"
  context="$2"
  contextID="$3"
  c="$4"
  out="$5"
  keyCode="$6"
  keyType="$7"
  extraInput="$8"

  f="keymaps/build/key_scripts/_$c$context.lua"
  cp keymaps/key_script_template.lua "$f"
  if [[ "$extraInput" != "" ]]; then
    echo "doInput({[\"key\"] = '$extraInput$out', [\"context\"] = '$context'})" >> "$f"
  else
    echo "doInput({[\"key\"] = '$out', [\"context\"] = '$context'})" >> "$f"
  fi

  # echo "end)" >> "$f"

  id="reaper-keys_$c$context"
  desc="Script: [reaper-keys] [$context] $c"
  genScript "$id" "$desc" "$f" "$contextID"
  genKey "$keyType" "$keyCode" "_$id" "$contextID" >> "$tmpFile"
}

function gen() {
  local name virtual_key keyCode keyType extraInput
  name="$1"
  virtual_key="$2"
  keyCode="$3"
  keyType="$4"
  extraInput="$5"
  if [[ "$keyType" == "" ]]; then
    keyType=1
  fi

  genContext  "$tmpKeys" "main" 0 "$name" "$virtual_key" "$keyCode" "$keyType" "$extraInput"
  genContext "$tmpKeys" "midi" 32060 "$name" "$virtual_key" "$keyCode" "$keyType" "$extraInput"
}


function genNumbers() {
    local numbers="0123456789"
    for (( i=0; i<${#numbers};i++ )) ; do
        local char="${numbers:$i:1}"
        gen "$char" "$char" $(( 48 + i ))
        gen "num_$char" "<num$char>" $(( 96 + i ))
        gen "alt_num_$char" "<num$char>" $(( 96 + i )) 17 "<alt>"
        gen "ctrl_num_$char" "<num$char>" $(( 96 + i )) 9 "<ctrl>"
    done
}

function genLetters() {
    local letters="abcdefghijklmnopqrstuvwxyz"
    for (( i=0; i<${#letters};i++ )) ; do
        local char="${letters:$i:1}"
        local upper=$(echo "$c" | tr '[:lower:]' '[:upper:]')
        local n=$(( 65 + i ))
        gen $char $char $(( 65 + i ))
        gen "big_$char" "$upper" "$n" 5
        gen "ctrl_big_$char" "$upper" "$n" 13 "<ctrl>"
        gen "alt_big_$char" "$upper" "$n" 21 "<alt>"
        gen "ctrl_$char" "$char" "$n"  9 "<ctrl>"
        gen "mod_$char" "$char" "$n"  33 "<mod>"
        gen "alt_$char" "$char" "$n"  17 "<alt>"
    done
}

genNumbers
genLetters

gen "esc" "<esc>" 27 1
gen "space" "<space>" 32 1
gen "ctrl_space" "<space>" 32 9 "<ctrl>"
gen "alt_space" "<space>" 32 17 "<alt>"

gen "period" "." 46 0
gen "left_shift" "<" 60 0
gen "right_shift" ">" 62 0
gen "colon" ":" 58 0
gen "cr" "<cr>" 13 1
gen "tab" "<tab>" 9 1
gen "backspace" "<bs>" 8 1
gen "comma" "," 44 0

gen "hyphen" "-"  45 0
gen "ctrl_hyphen" "-"  45 9 "<ctrl>"

gen "underscore" "_" 95 0
gen "semicolon" ";" 59 0
gen "questionmark" "?"  63 0

gen "plus" "+" 43 0
gen "ctrl_plus" "+" 43 9 "<ctrl>"

gen "apostrophe" "'" 222 0
gen "backslash" "\\\\" 220 0
gen "pipe" "|" 220 5

gen "slash" "/" 47 0
gen "numbersign" "#" 35 0
gen "at" "@" 64 0
gen "sectionsign" "§" 167 0
gen "tilde" "~" 126 0
gen "plusminus" "±" 177 0
gen "closebracket" "]" 93 0
gen "openbracket" "[" 91 0
gen "closewing" "}" 125 0
gen "openwing" "{" 123 0
gen "equals" "=" 61 0
gen "backtick" "\`" 96 0
gen "hook" "¬" 223 5 1

gen "left" "<left>" 32805 1
gen "up" "<up>" 32806 1
gen "right" "<right>" 32807 1
gen "down" "<down>" 32808 1

# works on windows
gen "openparen" "(" 57 5
gen "closeparen" ")" 48 5
gen "dollar" "$" 52 5
gen "percent" "%" 53 5
gen "ampersand" "&" 55 5
gen "exclamation" "!" 49 5
gen "quotation" "\"" 124 5
gen "big_left" "<LEFT>" 32805 5
gen "big_up" "<UP>" 32806 5
gen "big_right" "<RIGHT>" 32807 5
gen "big_down" "<DOWN>" 32808 5
# /) works on windows

# # # works on linux
# gen "openparen" "(" 40 0
# gen "closeparen" ")" 41 0
# gen "dollar" "$" 52 5
# gen "percent" "%" 37 0
# gen "ampersand" "&" 55 5
# gen "exclamation" "!" 49 5
# gen "quotation" "\"" 124 5
# gen "big_left" "<LEFT>" 32805 5
# gen "big_up" "<UP>" 32806 5
# gen "big_right" "<RIGHT>" 32807 5
# gen "big_down" "<DOWN>" 32808 5
# # # /> works on linux

# If you want to add another key but are unsure of the keycode, set your new key to an
# action via the action list in reaper, then export the key map, and look up the
# action code in the key map file to see the key code your new key uses.

cat "$tmpScripts" "$tmpKeys" > "$keymapFile"
rm "$tmpScripts" "$tmpKeys"
