%token <int> INT
%token <float> FLOAT
%token <string> IDENT
%token <string> STRING (* text surrounded by double quotes *)

%token CHANGE_COMMENT
%token TILDA
%token RESOURCE_KW

(* %token TRUE *)
(* %token FALSE *)
%token NULL
%token LEFT_BRACE
%token RIGHT_BRACE
%token LEFT_BRACK
%token RIGHT_BRACK
%token LEFT_PAREN
%token RIGHT_PAREN
%token EQUAL
%token ELLIPSIS
%token SLASH
%token PLUS
%token MINUS
%token LESS_THAN
%token COMMA
%token COLON
%token EOL
%token EOF

%start <Terraform.result option> prog

%%

prog:
| state_refreshes = list(state_refresh);
  legend;
  _terraform_will_perform_the_following_actions = section;
  resource_diffs = list(resource_diff);
  EOF
  { Some {
        resource_state_refreshes = state_refreshes;
        diffs = resource_diffs;
      }
  }
| EOF
  { None }
;

legend:
  | list(IDENT); COLON; list(legend_key) { () }

legend_key:
  | change_symbol; list(ident_or_parens) { () }

change_symbol:
  | PLUS
  | TILDA
  | MINUS
  | PLUS; SLASH; MINUS;
  | MINUS; SLASH; PLUS;
  | LESS_THAN; EQUAL;
    { () }

(* this can handle parsing words wrapped in parentheses, but it might be better
   to just allow optional LEFT_PAREN/RIGHT_PAREN tokens between each IDENT *)
ident_or_parens:
  | IDENT { () }
  | LEFT_PAREN; list(IDENT); RIGHT_PAREN; { () }

state_refresh:
  | IDENT; option(array_index); COLON; refreshing_state; new_value { () }

array_index:
  | LEFT_BRACK; INT; RIGHT_BRACK { () }

refreshing_state:
  | IDENT; IDENT { () }

new_value:
  | LEFT_BRACK; IDENT; EQUAL; v = IDENT; RIGHT_BRACK { v }

section:
  | _ids = list(IDENT); EOL; EOL { () }

resource_diff:
  | CHANGE_COMMENT;
    header = resource_diff_header;
    contents = diff_object;
    { Terraform.build_diff header contents }
    ;

resource_diff_header:
| TILDA; RESOURCE_KW; name = STRING; resource_type = STRING;
  { (name, resource_type) }

diff_object:
| LEFT_BRACE; kvs = list(diff_kv); RIGHT_BRACE
  { Terraform.build_changes kvs }

diff_kv:
| option(TILDA); k = IDENT; EQUAL; v = STRING { (k, v) }

diff_val:
  (* | LEFT_BRACE; obj_fields; RIGHT_BRACE { "object" } *)
  (* | LEFT_BRACK; list_fields; RIGHT_BRACK { "list" } *)
  | s = STRING { s }

(* obj_fields:
 *     obj = separated_list(COMMA, obj_field)    { obj } ;
 *
 * obj_field:
 *     k = STRING; EQUALS; v = diff_val              { (k, v) } ;
 *
 * list_fields:
 *     values = separated_list(COMMA, diff_val)         { values } ; *)
