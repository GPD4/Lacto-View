Readme lactoview-server -

1 . Certifique-se do caminho correto do 'lactoview4-c8c865e3ea92.json' de credenciais do firestore em '\lacto_view_server\lacto_view_server\routes\_middleware.dart'

2 . Acesse via terminal a pasta Raiz - '\LactoView_Mobile\lacto_view_server\lacto_view_server'

3 . 'dart_frog dev'

4 . Abra o '\LactoView_Mobile\lacto_view_server\lacto_view_server\get_token.html', pressione F12 e copie o Token.

5 . No postman a URL - http://localhost:8080/person_routes

6 . Vá em 'Authorization' selecione 'Bearer Token' e cole o Token.

7 . selecione o metodo POST e utilize em 'body' > 'raw' o json: 

{
    "name": "João Produtor",
    "cpf_cnpj": "11122233344",
    "email": "joao.produtor@lactoview.com",
    "phone": "45999887766",
    "role": "producer",
    "password": "senhaForte123!",
    "is_active": true,
    "profile_img": "http://example.com/images/joao.png"
}

