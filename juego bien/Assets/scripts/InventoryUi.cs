using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.Events;
using UnityEngine.SceneManagement;

public class InventoryUi : MonoBehaviour
{
    private TextMeshProUGUI CosechaText;
    private PlayerInventory playerInventory;

    // Start is called before the first frame update
    void Start()
    {
        CosechaText = GetComponent<TextMeshProUGUI>();

        if (playerInventory == null)
            playerInventory = FindObjectOfType<PlayerInventory>();

        UpdateCosechaText(playerInventory);

        playerInventory.OnCosechaCollected.AddListener(UpdateCosechaText);
        SceneManager.sceneLoaded += UpdateCosechaTextOnSceneLoad; // Suscribir al evento de carga de escena
    }

    void OnDestroy()
    {
        playerInventory.OnCosechaCollected.RemoveListener(UpdateCosechaText);
        SceneManager.sceneLoaded -= UpdateCosechaTextOnSceneLoad; // Desuscribir del evento de carga de escena
    }

    void UpdateCosechaTextOnSceneLoad(Scene scene, LoadSceneMode mode)
    {
        UpdateCosechaText(playerInventory);
    }

    public void UpdateCosechaText(PlayerInventory playerInventory)
    {
        int cosechas = playerInventory.NumberOfCosechas;
        // Solo actualiza el texto si el número de cosechas es diferente de cero
        if (cosechas != 0)
        {
            CosechaText.text = cosechas.ToString();
        }
        else
        {
            CosechaText.text = ""; // Si el número de cosechas es cero, vacía el texto
        }
    }
}










