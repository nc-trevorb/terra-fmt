{
open Parser

exception SyntaxError of string

let p debug label s = if debug then Printf.printf "%s: %s\n" label s
}

let int = '-'? ['0'-'9'] ['0'-'9']*
let digit = ['0'-'9']
let frac = '.' digit*
let exp = ['e' 'E'] ['-' '+']? digit+
let float = digit* frac? exp?
let whitespace = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
(* let blank_line = "\n\n" *)
let ident = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_' '.']*

rule read debug =
  parse
  | whitespace { read debug lexbuf }
  | newline    { Lexing.new_line lexbuf; read debug lexbuf }
  | int        { INT (int_of_string (Lexing.lexeme lexbuf)) }
  | float      { FLOAT (float_of_string (Lexing.lexeme lexbuf)) }
  (* | "true"     { TRUE } *)
  (* | "false"    { FALSE } *)
  | "null"     { NULL }
  | "resource" { RESOURCE_KW }
  | "# module" [^ '\n']* { CHANGE_COMMENT }
  | whitespace* "# (" [^ '\n']* '\n' { Lexing.new_line lexbuf; read debug lexbuf }
  | '~'        { TILDA }
  | '"'        { read_string (Buffer.create 17) lexbuf }
  | '{'        { LEFT_BRACE }
  | '}'        { RIGHT_BRACE }
  | '['        { LEFT_BRACK }
  | ']'        { RIGHT_BRACK }
  | '('        { LEFT_PAREN }
  | ')'        { RIGHT_PAREN }
  | '+'        { PLUS }
  | '-'        { MINUS }
  | '<'        { LESS_THAN }
  | '='        { EQUAL }
  | ','        { COMMA }
  | ':'        { COLON }
  | "..."      { ELLIPSIS }
  | ident      { p debug "ident" (Lexing.lexeme lexbuf); IDENT (Lexing.lexeme lexbuf) }
  | eof        { EOF }
  | _          { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
and read_string buf =
  parse
  | '"'       { STRING (Buffer.contents buf) }
  | '\\' '/'  { Buffer.add_char buf '/'; read_string buf lexbuf }
  | '\\' '\\' { Buffer.add_char buf '\\'; read_string buf lexbuf }
  | '\\' 'b'  { Buffer.add_char buf '\b'; read_string buf lexbuf }
  | '\\' 'f'  { Buffer.add_char buf '\012'; read_string buf lexbuf }
  | '\\' 'n'  { Buffer.add_char buf '\n'; read_string buf lexbuf }
  | '\\' 'r'  { Buffer.add_char buf '\r'; read_string buf lexbuf }
  | '\\' 't'  { Buffer.add_char buf '\t'; read_string buf lexbuf }
  | [^ '"' '\\']+
    { Buffer.add_string buf (Lexing.lexeme lexbuf);
      read_string buf lexbuf
    }
  | _ { raise (SyntaxError ("Illegal string character: " ^ Lexing.lexeme lexbuf)) }
  | eof { raise (SyntaxError ("String is not terminated")) }
