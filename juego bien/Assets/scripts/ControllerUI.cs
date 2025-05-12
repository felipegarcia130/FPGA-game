using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;
using System.IO.Ports;
using TMPro;

public class UIController : MonoBehaviour
{
    public int Reverse = 0;
    public int Drive = 0;
    public int Brake = 0;
    public int Right = 0;
    public int Left = 0;
    public SerialPort serialPort = new SerialPort("COM8", 115200);

    public TextMeshProUGUI amountPoints;
    string amountText = "Points: ";
    int currentScore = 0;

    void OnEnable()
    {
        Cosecha.cosechaCollectedEvent += AddPoints; // Subscribe to the cosecha collected event
    }

    void OnDisable()
    {
        Cosecha.cosechaCollectedEvent -= AddPoints; // Unsubscribe from the cosecha collected event
    }

    public void ActiveScore()
    {
        amountPoints.text = amountText + "--";
    }

    public void printScore()
    {
        amountPoints.text = amountText + currentScore.ToString();
        GameControl.Instance.checkGameOver(currentScore);
    }

    public void AddPoints()
    {

        currentScore += 1; // Assuming each cosecha collection adds 10 points

        if (!serialPort.IsOpen)
        {
            serialPort.Open();
            serialPort.ReadTimeout = 1;
        }

        if (serialPort.IsOpen)
        {
            //var dataByte = new byte[] { 0x00 };
            byte[] data = BitConverter.GetBytes(currentScore);
            serialPort.Write(data, 0, 1); // Clear FPGA's LEDs at start
        }
        printScore();
    }

    void Start()
    {
        ActiveScore();
        if (!serialPort.IsOpen)
        {
            serialPort.Open();
            serialPort.ReadTimeout = 1;
        }

        if (serialPort.IsOpen)
        {
            var dataByte = new byte[] { 0x00 };
            serialPort.Write(dataByte, 0, 1); // Clear FPGA's LEDs at start
        }
    }

    void Update()
    {
        if (!serialPort.IsOpen)
        {
            serialPort.Open();
            serialPort.ReadTimeout = 1;
        }

        if (serialPort.IsOpen)
        {
            try
            {
                int value;
                if (serialPort.BytesToRead > 0) // Verificar si hay nuevos datos recibidos
                {
                    value = serialPort.ReadByte(); // Leer el dato de 8 bits
                    serialPort.DiscardInBuffer();
                }
                else
                {
                    value = 0;
                }

                if (value == 0x01)
                {
                    Brake = 1;
                    Left = 0;
                    Right = 0;
                    Drive = 0;
                    Reverse = 0;
                }
                else if (value == 0x02)
                {
                    Drive = 1;
                }
                else if (value == 0x03)
                {
                    Left = 1;
                }
                else if (value == 0x04)
                {
                    Right = 1;
                }
                else if (value == 0x05)
                {
                    Reverse = 1;
                }
                else
                {
                    Brake = 0;
                }
            }
            catch { }
        }
    }
}
