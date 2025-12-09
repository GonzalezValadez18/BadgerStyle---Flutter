 # LeoFlutter - Aplicación de Gestión de Citas

 Un proyecto en Flutter diseñado como una aplicación para agendar y gestionar citas en una barbería o salón de belleza. La aplicación utiliza una base de datos local SQLite para persistir toda la información.
 
 ## ✨ Características Principales
 
 - **Autenticación de Usuarios:** Registro e inicio de sesión de usuarios.
 - **Gestión de Sesión:** Mantiene la sesión del usuario activa para una experiencia fluida.
 - **Catálogo de Servicios:** Muestra una lista de servicios disponibles (cortes, afeitado, etc.) con descripción, precio e imagen.
 - **Visualización de Citas:** Los usuarios pueden ver un listado de sus citas agendadas, tanto pendientes como completadas.
 - **Cancelación de Citas:** Permite a los usuarios cancelar sus citas pendientes.
 - **Base de Datos Local:** Utiliza `sqflite` para almacenar usuarios, servicios, citas y sesiones de forma local en el dispositivo.
 - **Interfaz de Usuario Clara:** Pantallas dedicadas para el inicio de sesión, la página principal y la visualización de citas.
 
 ## 📂 Estructura del Proyecto
 
 El proyecto sigue una arquitectura organizada para separar responsabilidades:
 
 ```
 lib/
 ├── dao/           # (Data Access Objects) Lógica de acceso a la base de datos.
 │   ├── date_dao.dart
 │   ├── service_dao.dart
 │   ├── session_dao.dart
 │   └── user_dao.dart
 │
 ├── database/      # Gestión de la base de datos (inicialización, tablas).
 │   ├── database_helper.dart
 │   └── tables.dart
 │
 ├── dto/           # (Data Transfer Objects) Clases para la creación de nuevos registros.
 │   ├── session_dto.dart
 │   ├── service_dto.dart
 │   └── user_dto.dart
 │
 ├── models/        # Modelos de datos que representan las tablas de la BD.
 │   ├── date_model.dart
 │   ├── service_model.dart
 │   └── user_model.dart
 │
 ├── screens/       # Widgets que representan las diferentes pantallas de la app.
 │   ├── home_screen.dart
 │   ├── login_screen.dart
 │   └── my_appointments_screen.dart
 │
 ├── utils/         # Clases de utilidad, como helpers para diálogos.
 │   └── dialog_helper.dart
 │
 └── main.dart      # Punto de entrada de la aplicación.
 ```
 
 ## 🚀 Cómo Empezar
 
 1.  **Clona el repositorio:**
     ```bash
     git clone <URL-DEL-REPOSITORIO>
     ```
 2.  **Instala las dependencias:**
     ```bash
     flutter pub get
     ```
 3.  **Ejecuta la aplicación:**
     ```bash
     flutter run
     ```
 
 ### 🛠️ Funcionalidad Clave
 
 - **`DatabaseHelper`**: Se encarga de inicializar la base de datos, crear las tablas la primera vez que se ejecuta la app e insertar un conjunto de servicios iniciales. También incluye una función `exportDB` para facilitar la depuración de la base de datos en dispositivos Android.
 - **Patrón DAO**: La interacción con la base de datos está encapsulada en clases `Dao`, lo que permite que el resto de la aplicación no se preocupe por las consultas SQL.
 - **Verificación de Sesión**: En `main.dart`, antes de iniciar la aplicación, se comprueba si existe una sesión activa para dirigir al usuario a la pantalla de `Login` o directamente a la `HomeScreen`.
