@echo off
setlocal enabledelayedexpansion

if not exist "C:\ProjetosPessoais" (
    mkdir "C:\ProjetosPessoais"
)
cd C:\ProjetosPessoais

set /p projectName=Digite o nome do projeto: 

echo Criando diretório "%projectName%"...
mkdir "%projectName%"

cd "%projectName%"

echo Criando projeto base api com o nome "%projectName%"...

dotnet new sln -n "%projectName%"

dotnet new webapi -n Api -f net8.0
dotnet new classlib -n Core -f net8.0
dotnet new classlib -n Infrastructure -f net8.0
dotnet new xunit -n Testes -f net8.0

cd Infrastructure
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL --version 9.0.4
dotnet add package Microsoft.EntityFrameworkCore --version 9.0.4

mkdir Data
cd Data
dotnet new class -n DataContext


:: CRIAÇÃO DATACONTEXT
set "arquivo=DataContext.cs"
:: Apagar se já existir
if exist "%arquivo%" del "%arquivo%"

echo using Core.Entities.Usuarios;>>"%arquivo%"
echo using Microsoft.EntityFrameworkCore;>>"%arquivo%"
echo using Microsoft.EntityFrameworkCore.Storage.ValueConversion;>>"%arquivo%"
echo.>>"%arquivo%"
echo namespace Infrastructure.Data>>"%arquivo%"
echo {>>"%arquivo%"
echo     public class DataContext : DbContext>>"%arquivo%"
echo     {>>"%arquivo%"
echo         public DataContext(DbContextOptions<DataContext> options) : base(options) { }>>"%arquivo%"
echo.>>"%arquivo%"
echo         protected override void OnModelCreating(ModelBuilder modelBuilder)>>"%arquivo%"
echo         {>>"%arquivo%"
echo             base.OnModelCreating(modelBuilder);>>"%arquivo%"
echo.>>"%arquivo%"
echo             modelBuilder.Entity^<^Usuario^>^().ToTable("usuarios");>>"%arquivo%"
echo.>>"%arquivo%"
echo             foreach (var entityType in modelBuilder.Model.GetEntityTypes())>>"%arquivo%"
echo             {>>"%arquivo%"
echo                 foreach (var property in entityType.GetProperties())>>"%arquivo%"
echo                 {>>"%arquivo%"

echo                     if (property.ClrType == typeof(DateTime) ^|^| property.ClrType == typeof(DateTime?))>>"%arquivo%"
echo                     {>>"%arquivo%"
echo                         property.SetValueConverter(new ValueConverter^<DateTime, DateTime^>(>>"%arquivo%"
echo                             v ^=^> v.Kind == DateTimeKind.Utc ? v : DateTime.SpecifyKind(v, DateTimeKind.Utc),>>"%arquivo%"
echo                             v ^=^> DateTime.SpecifyKind(v, DateTimeKind.Utc)>>"%arquivo%"
echo                         ));>>"%arquivo%"
echo                     }>>"%arquivo%"

echo                 }>>"%arquivo%"
echo             }>>"%arquivo%"
echo         }>>"%arquivo%"
echo.>>"%arquivo%"
echo         public DbSet<Usuario> Usuarios { get; set; }>>"%arquivo%"
echo     }>>"%arquivo%"
echo }>>"%arquivo%"


cd..\..

cd Testes
dotnet add package Moq --version 4.20.72
dotnet add package xunit --version 2.5.3
dotnet add package xunit.runner.visualstudio --version 2.5.3

cd..

dotnet sln "%projectName%".sln add Api Core Infrastructure Testes

dotnet add Testes reference Core
dotnet add Infrastructure reference Core
dotnet add Api reference Core
dotnet add Api reference Infrastructure

echo Acessando a pasta Core
cd Core
dotnet add package Microsoft.IdentityModel.Tokens --version 9.0.1
dotnet add package System.IdentityModel.Tokens.Jwt --version 8.12.0
mkdir Entities
cd Entities
mkdir Usuarios
cd Usuarios
dotnet new class -n Usuario

:: CRIAÇÃO USUARIO
:: Caminho e nome do arquivo
set "arquivo=Usuario.cs"

:: Apagar se já existir
if exist "%arquivo%" del "%arquivo%"

:: Escrever o conteúdo no arquivo
echo using System.ComponentModel.DataAnnotations;>>"%arquivo%"
echo using System.ComponentModel.DataAnnotations.Schema;>>"%arquivo%"
echo using System.Text.Json.Serialization;>>"%arquivo%"
echo.>>"%arquivo%"
echo namespace Core.Entities.Usuarios>>"%arquivo%"
echo {>>"%arquivo%"
echo     public class Usuario>>"%arquivo%"
echo     {>>"%arquivo%"
echo.>>"%arquivo%"
echo         [Key, Column("id"), JsonPropertyName("id")]>>"%arquivo%"
echo         public virtual int Id { get; set; }>>"%arquivo%"
echo.>>"%arquivo%"
echo         [Column("nome"), JsonPropertyName("nome")]>>"%arquivo%"
echo         public virtual string Nome { get; set; }>>"%arquivo%"
echo.>>"%arquivo%"
echo         [Column("login"), JsonPropertyName("login")]>>"%arquivo%"
echo         public virtual string Login { get; set; }>>"%arquivo%"
echo.>>"%arquivo%"
echo         [Column("senha"), JsonPropertyName("senha")]>>"%arquivo%"
echo         public virtual byte[] Senha { get; set; }>>"%arquivo%"
echo.>>"%arquivo%"
echo         [Column("hash"), JsonPropertyName("hash")]>>"%arquivo%"
echo         public virtual byte[] Hash { get; set; }>>"%arquivo%"
echo.>>"%arquivo%"
echo     }>>"%arquivo%"
echo }>>"%arquivo%"

cd..\..
mkdir Repositories
cd Repositories
dotnet new interface -n IUsuarioRepository



cd..\..
cd Core
mkdir Util
cd Util

echo Criando as classes utilitarias

dotnet new class -n Criptografia
dotnet new class -n Jwt
dotnet new class -n TokenSettings


:: CRIAÇÃO CRIPTOGRAFIA JWT
:: Caminho e nome do arquivo a ser criado

setlocal enabledelayedexpansion

:: Nome do arquivo de saída
set "arquivo=Criptografia.cs"

:: Apaga o arquivo anterior, se existir
if exist "%arquivo%" del "%arquivo%"

:: Escreve as linhas no arquivo
echo using System.Security.Cryptography;>>"%arquivo%"
echo using System.Text;>>"%arquivo%"
echo.>>"%arquivo%"
echo namespace Core.Util>>"%arquivo%"
echo {>>"%arquivo%"
echo     public class Criptografia>>"%arquivo%"
echo     {>>"%arquivo%"
echo         public static void CriarHashSalt(string str, out byte[] hash, out byte[] salt)>>"%arquivo%"
echo         {>>"%arquivo%"
echo             if (str == null)>>"%arquivo%"
echo                 throw new Exception("");>>"%arquivo%"
echo             if (string.IsNullOrWhiteSpace(str))>>"%arquivo%"
echo                 throw new Exception("");>>"%arquivo%"
echo.>>"%arquivo%"
echo             using (var hmac = new HMACSHA512())>>"%arquivo%"
echo             {>>"%arquivo%"
echo                 salt = hmac.Key;>>"%arquivo%"
echo                 hash = hmac.ComputeHash(Encoding.UTF8.GetBytes(str));>>"%arquivo%"
echo             }>>"%arquivo%"
echo         }>>"%arquivo%"
echo.>>"%arquivo%"
echo         public static bool VerificarHashSalt(string str, byte[] hash, byte[] salt)>>"%arquivo%"
echo         {>>"%arquivo%"
echo             if (string.IsNullOrWhiteSpace(str)) throw new Exception("Informe uma Senha");>>"%arquivo%"
echo             if (hash == null) throw new Exception("Não há uma senha cadastrada.");>>"%arquivo%"
setlocal disabledelayedexpansion
echo             if (hash.Length != 64) throw new Exception("Invalid length of password hash (64 bytes expected).");>>"%arquivo%"
echo             if (salt.Length != 128) throw new Exception("Invalid length of password salt (128 bytes expected).");>>"%arquivo%"
setlocal enabledelayedexpansion
echo.>>"%arquivo%"
echo             using (var hmac = new HMACSHA512(salt))>>"%arquivo%"
echo             {>>"%arquivo%"
echo                 var computedHash = hmac.ComputeHash(Encoding.UTF8.GetBytes(str));>>"%arquivo%"
echo                 for (int i = 0; i ^< computedHash.Length; i++)>>"%arquivo%"
echo                 {>>"%arquivo%"
setlocal disabledelayedexpansion
echo                     if (computedHash[i] != hash[i]) return false;>>"%arquivo%"
setlocal enabledelayedexpansion
echo                 }>>"%arquivo%"
echo             }>>"%arquivo%"
echo.>>"%arquivo%"
echo             return true;>>"%arquivo%"
echo         }>>"%arquivo%"
echo     }>>"%arquivo%"
echo }>>"%arquivo%"


:: CRIAÇÃO ARQUIVO JWT
set "arquivo=Jwt.cs"

:: Excluir se já existir
if exist "%arquivo%" del "%arquivo%"

:: Início da escrita
echo using Core.Entities.Usuarios;>>"%arquivo%"
echo using Microsoft.IdentityModel.Tokens;>>"%arquivo%"
echo using System.IdentityModel.Tokens.Jwt;>>"%arquivo%"
echo using System.Security.Claims;>>"%arquivo%"
echo using System.Text;>>"%arquivo%"
echo.>>"%arquivo%"
echo namespace Core.Util>>"%arquivo%"
echo {>>"%arquivo%"
echo     public static class Jwt>>"%arquivo%"
echo     {>>"%arquivo%"
echo         public static string GenerateToken(Usuario usuario, string secretKey)>>"%arquivo%"
echo         {>>"%arquivo%"
echo             var tokenHandler = new JwtSecurityTokenHandler();>>"%arquivo%"
echo             var key = Encoding.ASCII.GetBytes(secretKey);>>"%arquivo%"
echo.>>"%arquivo%"
echo             var tokenDescritor = new SecurityTokenDescriptor>>"%arquivo%"
echo             {>>"%arquivo%"
echo                 Subject = new ClaimsIdentity(new[]>>"%arquivo%"
echo                 {>>"%arquivo%"
echo                     new Claim(ClaimTypes.Name, usuario.Nome),>>"%arquivo%"
echo                     new Claim("Id", usuario.Id.ToString())>>"%arquivo%"
echo                 }),>>"%arquivo%"
echo                 Expires = DateTime.UtcNow.AddHours(12),>>"%arquivo%"
echo                 Issuer = "Issuer",>>"%arquivo%"
echo                 Audience = "Audience",>>"%arquivo%"
echo                 SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)>>"%arquivo%"
echo             };>>"%arquivo%"
echo.>>"%arquivo%"
echo             var token = tokenHandler.CreateToken(tokenDescritor);>>"%arquivo%"
echo             return tokenHandler.WriteToken(token);>>"%arquivo%"
echo         }>>"%arquivo%"
echo     }>>"%arquivo%"
echo }>>"%arquivo%"


:: CRIAÇÃO TOKENSETTINGS JWT
:: Nome do arquivo de saída
set "arquivo=TokenSettings.cs"

:: Apaga o arquivo anterior, se existir
if exist "%arquivo%" del "%arquivo%"

:: Escreve o conteúdo no arquivo
echo namespace Core.Util>>"%arquivo%"
echo {>>"%arquivo%"
echo     public class TokenSettings>>"%arquivo%"
echo     {>>"%arquivo%"
echo         public string Secret { get; set; }>>"%arquivo%"
echo         public string Audience { get; set; }>>"%arquivo%"
echo         public string Issuer { get; set; }>>"%arquivo%"
echo         public int Seconds { get; set; }>>"%arquivo%"
echo     }>>"%arquivo%"
echo }>>"%arquivo%"


echo.
echo Sucesso!
pause

echo Projeto %projectName% criado com sucesso !!
pause
