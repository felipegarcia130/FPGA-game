using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.SceneManagement;

public class Timer : MonoBehaviour
{
    [SerializeField] private TextMeshProUGUI timerText;
    private float timerTime;
    private bool timerActive = true;
    private static Timer instance;

    void Awake()
    {
        if (instance == null)
        {
            instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }
    }

    void Start()
    {
        SceneManager.sceneLoaded += OnSceneLoaded;
        SetInitialTimerTimeBasedOnLevel(SceneManager.GetActiveScene().name); // Inicializar con tiempo basado en el nivel actual al inicio
    }

    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        SetInitialTimerTimeBasedOnLevel(scene.name); // Ajustar el tiempo inicial basado en el nuevo nivel cargado
    }

    void Update()
    {
        if (timerActive && timerTime > 0)
        {
            timerTime -= Time.deltaTime;
            UpdateTimerDisplay();
        }
        else if (timerActive)
        {
            EndTime();
        }
    }

    private void EndTime()
    {
        timerActive = false;
        SceneManager.LoadScene("Perder");
    }

    private void SetInitialTimerTimeBasedOnLevel(string levelName)
    {
        // Configura diferentes tiempos iniciales dependiendo del nombre de la escena
        switch (levelName)
        {
            case "level 1":
                timerTime = 120f; // 1 minutos
                break;
            case "level 2":
                timerTime = 120f; // 10 minutos
                break;
            case "level 3":
                timerTime = 120f; // 15 minutos
                break;
            case "level 4":
                timerTime = 120f; // 15 minutos
                break;
            default:
                timerTime = 300f; // Tiempo por defecto
                break;
        }
        ResetTimer();
    }

    private void ResetTimer()
    {
        timerActive = true;
        UpdateTimerDisplay();
    }

    private void UpdateTimerDisplay()
    {
        int minutes = Mathf.FloorToInt(timerTime / 60);
        int seconds = Mathf.FloorToInt(timerTime % 60);
        timerText.text = string.Format("{0:00}:{1:00}", minutes, seconds);
    }

    void OnDestroy()
    {
        if (instance == this)
        {
            SceneManager.sceneLoaded -= OnSceneLoaded;
        }
    }
}


