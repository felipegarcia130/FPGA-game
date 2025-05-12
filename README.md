# 🚜 Aventura en el Campo de Maíz
## *Un videojuego interactivo controlado por FPGA*

![Banner del Proyecto](https://api.placeholder.com/1200/300?text=Aventura+en+el+Campo+de+Ma%C3%ADz)

[![Estado del Proyecto](https://img.shields.io/badge/Estado-Completado-brightgreen)](https://github.com/felipegarcia130/tractor-fpga-game)
[![Unity](https://img.shields.io/badge/Unity-2021.3-blue)](https://unity.com/)
[![FPGA](https://img.shields.io/badge/Intel-DE10--Lite-orange)](https://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=1021)
[![Licencia](https://img.shields.io/badge/Licencia-MIT-yellow)](LICENSE)

---

> "La fusión perfecta entre hardware programable y desarrollo de videojuegos"

## 📖 Descripción General

**Aventura en el Campo de Maíz** es un proyecto educativo e interactivo que combina la potencia del desarrollo de videojuegos en Unity 3D con programación hardware en VHDL. Este sistema integrado permite a los usuarios controlar un tractor virtual mediante componentes físicos programados en una FPGA Intel DE10-Lite, creando una experiencia inmersiva donde las acciones del mundo real afectan directamente al entorno virtual.

### 🎓 Proyecto Académico
Este proyecto representa la entrega final de la materia de Lógica Programable, demostrando la aplicación práctica de conceptos teóricos en un producto funcional y entretenido con potencial educativo.

![Captura del Juego](https://api.placeholder.com/800/400?text=Captura+del+Juego)

## 🎮 Características Principales

- **Controles físicos**: Interfaz tangible mediante FPGA que traduce movimientos reales a acciones en el juego
- **Entorno 3D inmersivo**: Campos de maíz detallados y dinámica realista del tractor
- **Sistema de niveles progresivos**: Dificultad creciente que desafía al jugador
- **Comunicación en tiempo real**: Integración perfecta entre hardware y software mediante protocolo UART
- **Retroalimentación visual**: Displays de 7 segmentos que muestran información del juego en el dispositivo físico

## 🧠 Objetivo del Juego

Ponte al volante de un tractor y navega a través de intrincados campos de maíz mientras:

- Recolectas cosechas para acumular puntos
- Buscas bidones de combustible para mantener tu tractor en funcionamiento
- Esquivas obstáculos que podrían dañar tu vehículo
- Completas objetivos específicos antes de que se agote el tiempo
- Superas niveles de dificultad progresiva

## ⚙️ Arquitectura del Sistema

```
┌─────────────────┐                 ┌────────────────────┐
│  Intel DE10-Lite │                 │    PC con Unity    │
│   (FPGA/VHDL)   │◄───UART/RS232───►│  (Motor de Juego)  │
└─────────────────┘                 └────────────────────┘
       ▲   ▲                                  ▼
       │   │                         ┌────────────────────┐
┌──────┘   └──────┐                 │  Pantalla de Juego  │
▼                 ▼                  └────────────────────┘
┌─────────────┐ ┌─────────────────┐
│ Acelerómetro│ │Switches/Botones │
└─────────────┘ └─────────────────┘
```

### 🔄 Flujo de Control

1. **Usuario** → Interactúa con los controles físicos de la FPGA
2. **FPGA** → Procesa entradas y envía comandos seriales
3. **Unity** → Recibe comandos e implementa la lógica de juego
4. **Motor de Física** → Simula el comportamiento del tractor
5. **Renderizado 3D** → Muestra resultados en pantalla

## 🕹️ Controles e Interfaz Física

### 📱 Controles Principales

| Componente | Función | Código UART |
|------------|---------|-------------|
| **Acelerómetro** | Control de dirección preciso | Valores variables |
| **SW0** | Acelerador (avance) | `0x02` |
| **SW1** | Giro a la izquierda | `0x03` |
| **SW2** | Giro a la derecha | `0x04` |
| **SW3** | Marcha atrás | `0x05` |
| **Botón KEY0** | Freno de emergencia | `0x01` |

### 🔢 Retroalimentación

- **Display de 7 segmentos**: Muestra en tiempo real:
  - Número de elementos recolectados
  - Tiempo restante (alternando)
  - Estado del vehículo

![Controles Físicos](https://api.placeholder.com/600/300?text=Controles+F%C3%ADsicos+FPGA)

## 📁 Estructura del Repositorio

```
tractor-fpga-game/
├── Uartdigikey/
│   └── Uart_Digikey/        # Implementación UART para comunicación serie
├── juego bien/              # Proyecto Unity completo
│   ├── Assets/              # Modelos 3D, texturas y scripts
│   ├── Scenes/              # Niveles del juego
│   └── Scripts/             # Código C# para la lógica del juego
├── .gitattributes           # Configuración para Git LFS y EOL
├── videofinal.mp4           # Demostración del proyecto
├── Entrega Fase 3 - Logica programable (1).pdf  # Documentación técnica
└── Presentación Reto - Equipo 5.pdf            # Slides de presentación
```

## 🔧 Tecnologías Utilizadas

### Software
- **Unity 3D 2021.3**: Motor de videojuegos para el desarrollo del entorno virtual
- **Visual Studio**: Entorno de desarrollo para programación C#
- **Quartus Prime Lite 21.1**: IDE para programación y síntesis de VHDL

### Hardware
- **Intel DE10-Lite (MAX 10 10M50DAF484C7G)**: FPGA para implementación de controles físicos
- **Acelerómetro ADXL345**: Sensor de movimiento integrado
- **Display de 7 segmentos**: Visualización de datos en hardware

### Lenguajes y Protocolos
- **VHDL**: Programación de la lógica de la FPGA
- **C#**: Scripts y comportamientos en Unity
- **UART/RS232**: Protocolo de comunicación serie a 9600 baudios

## 🚀 Instalación y Ejecución

### Requisitos Previos
- Intel Quartus Prime Lite 21.1 o superior
- Unity 2021.3 LTS o superior
- Placa Intel DE10-Lite 
- Cable USB tipo B
- PC con puerto USB disponible

### Configuración del Hardware
1. Conecta la placa Intel DE10-Lite a tu computadora mediante USB
2. Programa la FPGA usando el archivo `.sof` incluido o sintetiza el código VHDL
3. Verifica que los LEDs de estado se enciendan correctamente

### Configuración del Software
1. Clona este repositorio con Git LFS:
   ```bash
   git lfs install
   git clone https://github.com/felipegarcia130/tractor-fpga-game.git
   ```

2. Abre el proyecto en Unity:
   ```bash
   cd "juego bien"
   unity -projectPath .
   ```

3. En Unity, configura el puerto COM:
   - Abre la escena principal
   - Selecciona el objeto "SerialController"
   - En el Inspector, ajusta el puerto COM al que corresponda con tu FPGA 

4. ¡Ejecuta el juego y disfruta de la experiencia!

## 🎥 Video Demostrativo

[![Video Demostrativo](https://img.youtube.com/vi/Y7WADsOAQw4/0.jpg)](https://www.youtube.com/watch?v=Y7WADsOAQw4)

[Ver en YouTube](https://www.youtube.com/watch?v=Y7WADsOAQw4&ab_channel=eugeniomartinez)

## 🎯 Niveles y Progresión

| Nivel | Objetivo | Dificultad | Características |
|-------|----------|------------|-----------------|
| **1** | Recolectar 5 mazorcas | ⭐ | Tutorial, terreno plano |
| **2** | Recolectar 10 mazorcas + 2 bidones | ⭐⭐ | Obstáculos simples |
| **3** | Recolectar 15 mazorcas + 3 bidones | ⭐⭐⭐ | Terreno irregular, tiempo reducido |

## 🧪 Pruebas y Validación

Se implementaron pruebas exhaustivas para validar la comunicación entre la FPGA y Unity:

| Prueba | Código | Resultado Esperado | Estado |
|--------|--------|-------------------|--------|
| Giro a la derecha | `0x04` | Rotación suave a la derecha | ✅ |
| Giro a la izquierda | `0x03` | Rotación suave a la izquierda | ✅ |
| Freno de emergencia | `0x01` | Detención inmediata del vehículo | ✅ |
| Aceleración | `0x02` | Incremento progresivo de velocidad | ✅ |
| Marcha atrás | `0x05` | Movimiento inverso controlado | ✅ |

## 👨‍💻 Equipo de Desarrollo

| Miembro | ID | Rol |
|---------|----|----|
| **Alfonso Solís Díaz** | A00838034 | Programación VHDL y diseño de hardware |
| **Felipe de Jesús García García** | A01705893 | Integración UART y documentación |
| **Eugenio Javier Martínez Gastélum** | A0721946 | Desarrollo en Unity y diseño de niveles |

## 📄 Documentos Clave

- 📘 [Entrega Fase 3 - Lógica programable](./Entrega%20Fase%203%20-%20Logica%20programable%20(1).pdf) - Documentación técnica completa
- 📑 [Presentación Reto - Equipo 5](./Presentación%20Reto%20-%20Equipo%205.pdf) - Slides de la presentación final

## 🔮 Trabajo Futuro

- [ ] Implementación de efectos climáticos que afecten la jugabilidad
- [ ] Soporte para múltiples tipos de vehículos agrícolas
- [ ] Sistema de puntuación en línea y competencias
- [ ] Modos de juego adicionales (contrarreloj, cooperativo)
- [ ] Compatibilidad con VR para mayor inmersión

## 🔗 Recursos y Referencias

- [Conectando Arduino y Unity por UART](https://sensorizacion.blog.tartanga.eus/conectividad/conectando-arduino-y-unity-a-traves-del-puerto-serie/)
- [Documentación DE10-Lite](https://www.iuma.ulpgc.es/roberto//ed/practicas/DE10-Lite-info.html)
- [Implementación SPI en VHDL](https://www.boletin.upiita.ipn.mx/index.php/ciencia/745-cyt-numero-64/1453-implementacion-del-protocolo-de-comunicacion-spi-en-vhdl-para-el-modulo-pmodtc1)
- [Unity Manual: Serial Port Communication](https://docs.unity3d.com/Manual/SerialPort.html)
- [Quartus Prime Pro Edition User Guide](https://www.intel.com/content/www/us/en/docs/programmable/683432/21-4/user-guide.html)

## 📜 Licencia

Este proyecto está licenciado bajo los términos de la licencia MIT. Ver el archivo [LICENSE](LICENSE) para más detalles.

---

<p align="center">
  <i>Desarrollado como proyecto final para el curso de Lógica Programable</i><br>
  <i>© 2023 Equipo 5 - Todos los derechos reservados</i>
</p>
