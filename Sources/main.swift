import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import PostgreSQL
import SwiftyJSON

// Create HTTP server.
let server = HTTPServer()

// Register your own routes and handlers
var routes = Routes()
let psql = PGConnection()
let status = psql.connectdb("postgresql://pedrogomesbranco@localhost:5432/postgres")

print(status)
routes.add(method: .get, uri: "/cerveja", handler: {
  request, response in
  
  var cervejas: [[String:Any]] = []
  
  let queryResult = psql.exec(statement: "SELECT * FROM cerveja")

  print(queryResult.numTuples())
  
  for index in 0..<queryResult.numTuples() {
    var cerveja: [String:Any] = [:]
    cerveja["nome"] = queryResult.getFieldString(tupleIndex: index, fieldIndex: 0)
    cerveja["tipo"] = queryResult.getFieldString(tupleIndex: index, fieldIndex: 1)
    cerveja["teor"] = queryResult.getFieldFloat(tupleIndex: index, fieldIndex: 2)
    
    cervejas.append(cerveja)
  }
  
  let json = JSON(arrayLiteral: cervejas).rawString()
  
  response.setBody(string: json!)
  
  response.completed()
})

routes.add(method: .post, uri: "/cerveja") { (request, response) in
  let requestString = request.postBodyString!
  let json = JSON(parseJSON: requestString)
  let nome = json["nome"].stringValue
  let tipo = json["tipo"].stringValue
  let teor = json["teor"].doubleValue
  
  print(nome, tipo, teor)
  
  let insertQuery = psql.exec(statement: "INSERT INTO cerveja(nome, tipo, teor) VALUES ($1, $2, $3)", params: [nome, tipo, teor])
  
  response.completed()
}

server.addRoutes(routes)

// serve static content, including the index.html file
// remember to add files in ./webroot to the buildphase in xcode, to "copyfiles"
server.documentRoot = "./webroot"
// Add the routes to the server.
server.addRoutes(routes)

// Set a listen port of 8080
server.serverPort = 8080

do {
  // Launch the HTTP server.
  try server.start()
} catch PerfectError.networkError(let err, let msg) {
  print("Network error thrown: \(err) \(msg)")
}
