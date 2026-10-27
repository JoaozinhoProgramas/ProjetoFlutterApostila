class ApiConfig { 
 // Para Flutter Web local: http://localhost:8080/api 
 // Para emulador Android: http://10.0.2.2:8080/api 
 // Para o Render: https://seu-servico.onrender.com/api 
 // Também é possível informar em tempo de execução: 
 // flutter run -d chrome --dart-define=API_URL=https://.../api 
 static const String baseUrl = String.fromEnvironment( 
 'API_URL', 
 defaultValue: 'https://gestao-comercial-api.onrender.com/api', 
 ); 
} 
