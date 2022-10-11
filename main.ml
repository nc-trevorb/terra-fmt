open Lexing

let print_position outx lexbuf =
  let pos = lexbuf.lex_curr_p in
  Printf.fprintf outx "%s:%d:%d" pos.pos_fname
    pos.pos_lnum (pos.pos_cnum - pos.pos_bol + 1)

let parse_with_error lexbuf =
  try Parser.prog Lexer.read lexbuf with
  | Lexer.SyntaxError msg ->
     Printf.fprintf stderr "%a: (lex) %s\n" print_position lexbuf msg;
     None
  | Parser.Error ->
     Printf.fprintf stderr "%a: (parse) syntax error\n" print_position lexbuf;
     exit (-1)

let rec parse ?(print=false) lexbuf =
  match parse_with_error lexbuf with
  | Some result ->
     (
       if print then (
         Printf.printf "%d resource state refreshes\n" (List.length result.resource_state_refreshes);
         Printf.printf "%d diffs:\n" (List.length result.diffs);
         List.iter Terraform.print_diff result.diffs
       );
      parse ~print lexbuf
     )
  | None ->
     (* let _ = raise (Failure "parse None") in *)
     ()

let loop filename () =
  let inx = In_channel.open_text filename in
  let lexbuf = Lexing.from_channel inx in
  lexbuf.lex_curr_p <- { lexbuf.lex_curr_p with pos_fname = filename };
  parse ~print:true lexbuf;
  In_channel.close inx

let () =
  Core.Command.basic_spec ~summary:"Parse terraform output"
    Core.Command.Spec.(empty +> anon ("filename" %: string))
    loop
  |> Command_unix.run
