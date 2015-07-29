SMAPEper <- function(x,y){
  num <- abs(x-y)
  deno <- abs(x) + abs(y)
  result <- mean((200*num)/deno)
  return(result)
  }

MAPE <- function(x,y){
  return(mean(abs((x - y)/x))*100)
}