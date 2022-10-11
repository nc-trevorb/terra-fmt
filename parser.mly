%token <int> INT
%token <float> FLOAT
%token <string> IDENT
%token <string> STRING (* text surrounded by double quotes *)
%token <string> SECTION (* text followed by a blank line FIXME: this should be a rule instead of a token *)

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
%token EQUAL
%token COMMA
%token EOL
%token EOF

%start <Terraform.result option> prog

%%

prog:
| state_refreshes = SECTION;
  _legend = SECTION;
  _terraform_will_perform_the_following_actions = SECTION;
  resource_diffs = list(resource_diff);
  EOF
  { Some {
        resource_state_refreshes = Str.split (Str.regexp "\n") state_refreshes;
        diffs = resource_diffs;
      }
  }
| EOF
  { None }
;

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
| option(TILDA); k = STRING; EQUAL; v = STRING { (k, v) }

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
