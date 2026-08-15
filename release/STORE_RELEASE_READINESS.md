# GASTROORIGEN — Preparación para App Store y Google Play

Estado: PREPARACIÓN DE PUBLICACIÓN

Este documento controla lo necesario para convertir el código Flutter actual en una aplicación firmada y distribuible para iPhone/iPad y Android.

## Estado actual del repositorio

- Código Flutter principal: presente.
- Cámara/galería y flujo de análisis: presentes.
- Backend remoto: integrado.
- Assets de marca: presentes.
- Versión actual en `pubspec.yaml`: `0.1.0+1`.
- Carpetas nativas `android/` e `ios/`: pendientes de generar y revisar.
- Firma Android: pendiente.
- Firma Apple: pendiente.
- Identificador definitivo (Bundle ID / Application ID): pendiente de confirmar con la cuenta propietaria.
- Icono definitivo de tienda: pendiente de preparar a partir del activo oficial autorizado.
- Política de privacidad pública: borrador pendiente de datos legales/contacto.

## Identidad de publicación

Nombre visible: GASTROORIGEN

Identificador propuesto (NO fijar hasta confirmación): `mx.gastroorigen.app`

Regla: una vez publicado, no cambiar el identificador de paquete. Debe quedar registrado bajo las cuentas oficiales de GASTROORIGEN.

## Android / Google Play

Preparar la envoltura Android con herramientas Flutter actuales y apuntar desde el inicio a la política vigente de Google Play. Para una app nueva que se envíe a partir del 31 de agosto de 2026, planear `targetSdk` 36 (Android 16) o posterior.

Antes de producción:

- Generar `android/` con Flutter estable actual.
- Definir `applicationId` definitivo.
- Configurar permisos mínimos: cámara e imágenes/fotografías según versión de Android.
- Verificar que la app no solicite permisos innecesarios.
- Generar keystore de producción fuera del repositorio.
- Guardar secretos de firma únicamente en un gestor seguro/CI.
- Configurar Play App Signing.
- Generar Android App Bundle `.aab` en modo release.
- Probar instalación y cámara en dispositivos físicos.
- Completar Data safety, clasificación de contenido y ficha de Play Store.

## iOS / iPadOS / App Store

Preparar la envoltura iOS con Flutter estable actual y Xcode compatible con los requisitos vigentes de Apple. Desde el 28 de abril de 2026, las cargas de iOS/iPadOS deben construirse con iOS/iPadOS 26 SDK o posterior.

Antes de producción:

- Generar `ios/` con Flutter estable actual.
- Definir Bundle Identifier definitivo.
- Configurar equipo (Team) de Apple Developer propiedad de GASTROORIGEN.
- Configurar descripciones de uso de cámara y biblioteca de fotos en `Info.plist`.
- Revisar orientación y comportamiento en iPhone y iPad.
- Configurar firma automática o manual con certificados/perfiles oficiales.
- Generar Archive de Release con Xcode.
- Probar primero mediante TestFlight.
- Completar App Privacy, clasificación por edad, screenshots y ficha de App Store Connect.

## Privacidad y seguridad

La aplicación envía fotografías al backend de GASTROORIGEN para analizarlas. Antes de publicación debemos documentar con precisión:

- qué datos se envían;
- si se almacenan o se procesan temporalmente;
- tiempo de conservación;
- proveedores subyacentes utilizados por el servidor (sin necesidad de mostrarlos como marca dentro de la interfaz);
- mecanismos de eliminación/contacto;
- correo oficial de privacidad/soporte.

Nunca guardar claves API ni certificados de firma dentro del repositorio público.

## Calidad mínima antes de enviar

- `flutter analyze` sin errores.
- pruebas de cámara y galería en Android físico.
- pruebas de cámara y galería en iPhone físico.
- prueba en tablet Android y iPad.
- prueba con conexión lenta, sin conexión y errores del backend.
- portada/splash sin deformación ni pixelación.
- icono y nombre correctos en launcher/home screen.
- ninguna referencia técnica de proveedor visible al usuario.
- URL de política de privacidad operativa.
- URL de soporte operativa.
- versión y número de compilación incrementados en cada entrega.

## Bloqueos que requieren intervención del propietario

1. Confirmar el identificador definitivo de paquete.
2. Crear/verificar Apple Developer y Google Play Console.
3. Confirmar nombre legal del titular/organización.
4. Proporcionar correo oficial de soporte y privacidad.
5. Aceptar contratos, verificaciones de identidad y pagos de las tiendas.
6. Crear y custodiar credenciales/certificados de firma.

## Estrategia recomendada

Primero: generar wrappers nativos y hacer builds de desarrollo.

Después: prueba interna Android + TestFlight.

Finalmente: completar metadatos, privacidad, capturas, firma de producción y enviar a revisión.
