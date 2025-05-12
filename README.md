# 🚜 Aventura en el Campo de Maíz - FPGA + Unity Game

**Proyecto final de lógica programable:** un videojuego educativo e interactivo en Unity 3D, controlado con una placa FPGA Intel DE10-Lite, que simula la conducción de un tractor en campos de maíz.

## 🎮 Descripción General

Este proyecto combina desarrollo de videojuegos en Unity con programación en VHDL y lógica embebida en una FPGA, para crear una experiencia inmersiva de conducción y recolección en un entorno agrícola simulado. Se integran entradas físicas (switches, acelerómetro y botones) que controlan el juego en tiempo real mediante comunicación serial.

> “Toda la programación en VHDL y Unity para un juego de un tractor controlado por una FPGA.”

## 📁 Estructura del Repositorio


## 🔧 Tecnologías Utilizadas

- **Unity 3D** para el desarrollo del videojuego.
- **Intel DE10-Lite (FPGA)** para el control físico del tractor.
- **VHDL** para lógica programable.
- **UART (Serial)** para la comunicación entre FPGA y computadora.
- **C#** para scripts y lógica en Unity.

## 🧠 Objetivo del Juego

Controla un tractor a través de campos de maíz para recolectar cosechas y bidones de combustible, evitando obstáculos y cumpliendo con los objetivos antes de que se acabe el tiempo. El reto aumenta a medida que se avanza por niveles progresivamente más difíciles.

## ⚙️ Interfaz Física

- 🎮 **Acelerómetro**: Dirección del tractor.
- 🔀 **Switches**:
  - SW0: Avanzar
  - SW1: Girar izquierda
  - SW2: Girar derecha
  - SW3: Reversa
- 🅱️ **Botón**: Freno del tractor.
- 🔢 **Displays de 7 segmentos**: Contador de objetos recolectados.

## 🕹️ Dinámica de Juego

- Cada nivel exige recolectar una cantidad mínima de objetos y gasolina.
- Si el tiempo expira sin alcanzar los objetivos, se repite el nivel.
- El movimiento del tractor responde en tiempo real a los controles físicos mediante comunicación UART.

## 🧪 Pruebas Implementadas

1. **Giro a la derecha** (código `0x04`)
2. **Giro a la izquierda** (código `0x03`)
3. **Freno de emergencia** (código `0x01`)

## 🎥 Video Demostrativo

[Ver en YouTube](https://www.youtube.com/watch?v=Y7WADsOAQw4&ab_channel=eugeniomartinez)

## 👨‍💻 Integrantes del Equipo

- Alfonso Solís Díaz – A00838034  
- Felipe de Jesús García García – A01705893  
- Eugenio Javier Martínez Gastélum – A0721946  

## 📄 Documentos Clave

- 📘 [`Entrega Fase 3 - Logica programable (1).pdf`](./Entrega%20Fase%203%20-%20Logica%20programable%20(1).pdf)
- 📑 [`Presentación Reto - Equipo 5.pdf`](./Presentación%20Reto%20-%20Equipo%205.pdf)

## 🔗 Recursos y Referencias

- [Conectando Arduino y Unity por UART](https://sensorizacion.blog.tartanga.eus/conectividad/conectando-arduino-y-unity-a-traves-del-puerto-serie/)
- [Documentación DE10-Lite](https://www.iuma.ulpgc.es/roberto//ed/practicas/DE10-Lite-info.html)
- [Implementación SPI en VHDL](https://www.boletin.upiita.ipn.mx/index.php/ciencia/745-cyt-numero-64/1453-implementacion-del-protocolo-de-comunicacion-spi-en-vhdl-para-el-modulo-pmodtc1)

---

¡Gracias por revisar este repositorio! Si deseas más detalles técnicos, revisa el PDF de la entrega final.
