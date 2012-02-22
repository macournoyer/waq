require "socket"
require "http/parser"

server = Socket.new(:INET, :STREAM, 0)
server.setsockopt(:SOCKET, :REUSEADDR, true)
server.bind(Socket.sockaddr_in(3000, "0.0.0.0"))
server.listen(10)

loop do
  socket, info = server.accept
  parser = Http::Parser.new

  # Lit et analyze la requete
  parser << socket.recv(4096) # 4 Ko
  
  # Traite la requete
  file = "." + parser.request_path # /index.html => ./index.html
  if parser.http_method == "GET" && File.file?(file)
    body = File.read(file)
  else
    body = "Ya rien ici..."
  end
  
  # Envoie la response
  socket.write("HTTP/1.1 OK 200\r\n")
  socket.write("Content-Type: text/html\r\n")
  socket.write("Content-Length: #{body.size}\r\n")
  socket.write("\r\n")
  socket.write(body)

  socket.shutdown
end
