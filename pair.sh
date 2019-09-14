datatype pair
constructor pair . .

fst () {
  destruct $1 pair x _
  echo $x
}

snd () {
  destruct $1 pair _ y
  echo $y
}
