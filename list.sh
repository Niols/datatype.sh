datatype list
constructor nil
constructor cons . list

list_length () {
  ## length: list -> int

  case $(match "$1") in
    nil)
    echo 0
    ;;

    cons) destruct "$1" cons _ _list_tl
    echo $((1 + $(length "$_list_tl")))
    ;;
  esac
}

list_hd () {
  ## hd: list -> .

  case $(match "$1") in
    nil)
    return 1
    ;;

    cons) destruct "$1" cons _list_hd _
    echo "$_list_hd"
    ;;
  esac
}

list_tl () {
  ## tl: list -> list

  case $(match "$1") in
    nil)
    return 1
    ;;

    cons) destruct "$1" cons _ _list_tl
    echo "$_list_tl"
    ;;
  esac
}

list_nth () {
  ## nth: list -> int -> .

  case $(match "$1") in
    nil)
    return 1
    ;;

    cons) destruct "$1" cons _list_hd _list_tl
    if [ "$2" -eq 0 ]; then
      echo "$_list_hd"
    else
      nth "$_list_tl" $(($2 - 1))
    fi
    ;;
  esac
}

list_rev () {
  ## rev: list -> list
  list_rev_append "$1" "$(nil)"
}

list_rev_append () {
  ## rev_append: list -> list -> list

  case $(match "$1") in
    nil)
    echo "$2"
    ;;

    cons) destruct $1 cons _list_hd _list_tl
    list_rev_append "$_list_tl" "$(cons "$_list_hd" "$2")"
    ;;
  esac
}

list_append () {
  ## append: list -> list -> list

  list_rev_append "$(rev "$1")" "$2"
}

## Iterators

list_iter () {
  ## iter: fun -> list -> void

  case $(match "$2") in
    nil) : ;;

    cons) destruct "$2" cons _list_hd _list_tl
    "$1" "$_list_hd"
    list_iter "$1" "$_list_tl"
    ;;
  esac
}

list_map () {
  ## map: fun -> list -> list

  case $(match "$2") in
    nil)
    nil
    ;;

    cons) destruct "$2" cons _list_hd _list_tl
    cons "$("$1" "$_list_hd")" "$(list_map "$1" "$_list_tl")"
    ;;
  esac
}
