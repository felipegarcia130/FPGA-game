using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class GameControl : MonoBehaviour
{
    public static GameControl Instance;
    public GameObject birdBehaviour;
    public UIController UIController;
    private Dictionary<string, int> pointsToWinByLevel = new Dictionary<string, int>();

    private int pointsToWin; // Ahora esta variable será actualizada dinámicamente
    private PlayerInventory playerInventory; // Referencia al PlayerInventory

    // Define los puntos necesarios para ganar en cada nivel
    void InitializePointsToWinByLevel()
    {
        pointsToWinByLevel.Add("level 1", 11);
        pointsToWinByLevel.Add("level 2", 12);
        pointsToWinByLevel.Add("level 3", 13);
        pointsToWinByLevel.Add("level 4", 14);
    }

    // Método para actualizar los puntos necesarios para ganar según la escena actual
    void UpdatePointsToWin()
    {
        string currentScene = SceneManager.GetActiveScene().name;
        if (pointsToWinByLevel.ContainsKey(currentScene))
        {
            pointsToWin = pointsToWinByLevel[currentScene];
        }
    }

    private void Awake()
    {
        

        InitializePointsToWinByLevel();
        SceneManager.sceneLoaded += OnSceneLoaded; // Suscribirse al evento de carga de escena
        SceneManager.sceneUnloaded += OnSceneUnloaded; // Suscribirse al evento de descarga de escena
    }

    private void Start()
    {
        UpdatePointsToWin(); // Actualizar los puntos necesarios para ganar al iniciar
        UpdateCosechaTextOnSceneLoad(); // Actualizar el contador de cosechas al iniciar
    }

    private void OnDestroy()
    {
        SceneManager.sceneLoaded -= OnSceneLoaded;
        SceneManager.sceneUnloaded -= OnSceneUnloaded;
    }

    // Método llamado cada vez que se carga una nueva escena
    void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        UpdatePointsToWin(); // Actualizar los puntos necesarios para ganar al cargar una nueva escena
        UpdateCosechaTextOnSceneLoad(); // Actualizar el contador de cosechas al cargar una nueva escena
        UpdatePlayerInventoryReference(); // Actualizar la referencia al PlayerInventory
    }

    // Método llamado cada vez que se descarga una escena
    void OnSceneUnloaded(Scene scene)
    {
        UpdatePlayerInventoryReference(); // Actualizar la referencia al PlayerInventory
    }

    // Método para actualizar el contador de cosechas al cargar una nueva escena
    void UpdateCosechaTextOnSceneLoad()
    {
        // Verificar si el PlayerInventory está disponible
        if (playerInventory != null)
        {
            // Obtener todos los objetos en la escena con el componente InventoryUi
            InventoryUi[] inventoryUIs = FindObjectsOfType<InventoryUi>();
            foreach (InventoryUi inventoryUi in inventoryUIs)
            {
                // Actualizar el contador de cosechas en cada objeto InventoryUi
                inventoryUi.UpdateCosechaText(playerInventory);
            }
        }
    }

    // Método para actualizar la referencia al PlayerInventory
    void UpdatePlayerInventoryReference()
    {
        playerInventory = FindObjectOfType<PlayerInventory>();
        if (playerInventory == null)
        {
            Debug.LogWarning("PlayerInventory not found in the scene.");
        }
    }

    public void ActiveEndScene()
    {
        // Verifica si la escena actual es el nivel 4
        if (SceneManager.GetActiveScene().name == "level 4")
        {
            SceneManager.LoadScene("Credits"); // Carga la escena de créditos
        }
        else
        {
            SceneManager.LoadScene("Ganar"); // Carga la escena de ganar
        }
    }


    public void checkGameOver(int _currentScore)
    {
        if (_currentScore >= pointsToWin)
        {
            ActiveEndScene();
        }
    }

    // Método para obtener los puntos necesarios para ganar
    public int GetPointsToWin()
    {
        return pointsToWin;
    }
}











