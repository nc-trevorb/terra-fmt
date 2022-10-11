{
open Parser

exception SyntaxError of string
}

let int = '-'? ['0'-'9'] ['0'-'9']*
let digit = ['0'-'9']
let frac = '.' digit*
let exp = ['e' 'E'] ['-' '+']? digit+
let float = digit* frac? exp?
let whitespace = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
(* let blank_line = "\n\n" *)
let id = ['a'-'z' 'A'-'Z' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*

rule read =
  parse
  | whitespace { read lexbuf }
  | newline    { Lexing.new_line lexbuf; read lexbuf }
  | int        { INT (int_of_string (Lexing.lexeme lexbuf)) }
  | float      { FLOAT (float_of_string (Lexing.lexeme lexbuf)) }
  (* | "true"     { TRUE } *)
  (* | "false"    { FALSE } *)
  | "null"     { NULL }
  | "resource" { RESOURCE_KW }
  | "# module" [^ '\n']* { CHANGE_COMMENT }
  | whitespace* "# (" [^ '\n']* '\n' { Lexing.new_line lexbuf; read lexbuf }
  (* | whitespace* "# (" [^ '\n']* '\n' { print_endline "matched ws"; Lexing.new_line lexbuf; read lexbuf } *)
  | '~'        { TILDA }
  | '"'        { read_string (Buffer.create 17) lexbuf }
  | '{'        { LEFT_BRACE }
  | '}'        { RIGHT_BRACE }
  | '['        { LEFT_BRACK }
  | ']'        { RIGHT_BRACK }
  | '='        { EQUAL }
  | ','        { COMMA }
  | _          {
        (* FIXME should return an IDENT *)
        let buf = (Buffer.create 17) in
        Buffer.add_string buf (Lexing.lexeme lexbuf);
        read_section false buf lexbuf
      }
  (* | _          { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) } *)
  | eof        { EOF }
and read_section last_char_was_newline buf =
  parse
  | '\n' {
    Lexing.new_line lexbuf;
    if last_char_was_newline then
      SECTION (Buffer.contents buf)
    else
      (Buffer.add_string buf (Lexing.lexeme lexbuf); read_section true buf lexbuf)
    }
  | eof {
    (* the last section in a file doesn't need the trailing blank line *)
    SECTION (Buffer.contents buf)
    }
  | whitespace* "# (" [^ '\n']* '\n' { Lexing.new_line lexbuf; read_section true buf lexbuf }
  | _ {
    Buffer.add_string buf (Lexing.lexeme lexbuf); read_section false buf lexbuf
    }
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
