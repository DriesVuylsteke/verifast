open Printf

let usage_error () =
  prerr_endline "Syntax error. Usage: java_card_applet mypackage.MyApplet [12,34,56,78]";
  exit 1

let split c s =
  let rec iter k =
    try
      let offset = String.index_from s k c in
      String.sub s k (offset - k)::iter (offset + 1)
    with Not_found -> [String.sub s k (String.length s - k)]
  in
  iter 0

let rec mk_list_expr ss =
  match ss with
    [] -> "nil"
  | s::ss -> Printf.sprintf "cons<byte>(%s, %s)" s (mk_list_expr ss)

let () =
  let args = 
    match Array.to_list Sys.argv with 
    | _::args -> args
    | _ -> assert false
  in
  let appletClass, args =
    match args with
      appletClass::args -> appletClass, args
    | _ -> usage_error ()
  in
  let arrayValue, args =
    match args with
      values::args ->
      mk_list_expr (split ',' values), args
    | _ ->
      "_", args
  in
  if args <> [] then usage_error ();
  
  printf "// This file is autogenerated by VeriFast to check the contract of the applet's install method.\n";
  printf "\n";
  printf "import javacard.framework.*;\n";
  printf "\n";
  printf "class JavaCardAppletTest {\n";
  printf "    static void test(byte[] buffer, short offset, byte length)\n";
  printf "        //@ requires array_slice(buffer, offset, length, %s) &*& offset + length <= 32768 &*& system() &*& class_init_token(%s.class);\n" arrayValue appletClass;
  printf "        //@ ensures true;\n";
  printf "    {\n";
  printf "        %s.install(buffer, offset, length);\n" appletClass;
  printf "    }\n";
  printf "}\n"
