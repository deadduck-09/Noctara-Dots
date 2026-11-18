#!/usr/bin/env bash
declare -A prev


niri msg --json event-stream | while read -r line; do
  [[ $line == *WindowOpenedOrChanged* || $line == *WindowClosed* ]] || continue


  windows=$(niri msg --json windows)
  unset now; declare -A now
  for k in "${!prev[@]}"; do now[$k]=0; done
  while read -r ws n; do now[$ws]=$n; done < <(
    jq -r '[.[]|select(.is_floating==false and .workspace_id!=null)]
           |group_by(.workspace_id)[]
           |"\(.[0].workspace_id) \(length)"' <<<"$windows")


  for ws in "${!now[@]}"; do
    old=${prev[$ws]:-0}; new=${now[$ws]}
    [[ $old == "$new" ]] && continue
    ids=$(jq -r --argjson ws "$ws" \
      '.[]|select(.workspace_id==$ws and .is_floating==false)|.id' <<<"$windows")
    if (( new == 1 )); then
      niri msg action set-window-width --id "$ids" 100%
    elif (( new == 2 && old == 1 )); then
      for id in $ids; do niri msg action set-window-width --id "$id" 50%; done
    fi
    prev[$ws]=$new
  done
done#!/usr/bin/env bash
declare -A prev


niri msg --json event-stream | while read -r line; do
  [[ $line == *WindowOpenedOrChanged* || $line == *WindowClosed* ]] || continue


  windows=$(niri msg --json windows)
  unset now; declare -A now
  for k in "${!prev[@]}"; do now[$k]=0; done
  while read -r ws n; do now[$ws]=$n; done < <(
    jq -r '[.[]|select(.is_floating==false and .workspace_id!=null)]
           |group_by(.workspace_id)[]
           |"\(.[0].workspace_id) \(length)"' <<<"$windows")


  for ws in "${!now[@]}"; do
    old=${prev[$ws]:-0}; new=${now[$ws]}
    [[ $old == "$new" ]] && continue
    ids=$(jq -r --argjson ws "$ws" \
      '.[]|select(.workspace_id==$ws and .is_floating==false)|.id' <<<"$windows")
    if (( new == 1 )); then
      niri msg action set-window-width --id "$ids" 100%
    elif (( new == 2 && old == 1 )); then
      for id in $ids; do niri msg action set-window-width --id "$id" 50%; done
    fi
    prev[$ws]=$new
  done
done
