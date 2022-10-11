type resource_type =
  | BUCKET_NOTIFICATION

type change = {
    key : string;
    value : string;
  }

type resource_diff = {
    name : string;
    type_ : resource_type;
    changes : change list;
  }

type result =
  { resource_state_refreshes : string list ;
    diffs : resource_diff list
  }
let type_to_string t : string =
  match t with
  | BUCKET_NOTIFICATION -> "Bucket notification"

let build_changes (changes : (string * string) list) : change list =
  List.map (fun (key, value) -> { key; value }) changes

let print_change (c : change) : unit =
  Printf.printf "    %s -> %s\n" c.key c.value

let build_diff (name, resource_type) changes : resource_diff =
  let type_ = match resource_type with
    | "bucket_notification" -> BUCKET_NOTIFICATION
    | _ -> raise (Failure ("unknown resource type: " ^ resource_type))
  in
  { name; type_; changes }

let print_diff (diff : resource_diff) : unit =
  Printf.printf "  %s %s\n" (diff.type_ |> type_to_string) diff.name;
  List.iter print_change diff.changes

(* type value =
 *   [ `Obj of obj
 *   | `Bool of bool
 *   | `Float of float
 *   | `Int of int
 *   | `List of value list
 *   | `Null
 *   | `String of string ]
 *   and obj = (string * value) list *)

(* and print_obj (obj : obj) : string =
 *   (\* let _ = raise (Failure "\n\nin print_obj\n\n") in *\)
 *   let lines = ref ["{ "] in
 *   let sep = ref "" in
 *   List.iter
 *     (fun (key, v) ->
 *       Printf.printf "%s\"%s\": %s" !sep key (print_section v);
 *       sep := ",\n  ")
 *     obj;
 *   lines := !lines @ [" }"];
 *   String.concat "\n" !lines *)

(* and print_list (arr : section list) : string =
 *   (\* let _ = raise (Failure "\n\nin print_list\n\n") in *\)
 *   let lines = ref ["["] in
 *   List.iteri
 *     (fun i v ->
 *       let prefix = if i > 0 then ", " else "" in
 *       lines := !lines @ [Printf.sprintf "%s%s" prefix (print_section v)]
 *       )
 *     arr;
 *   lines := !lines @ ["]"];
 *   String.concat "\n" !lines *)
