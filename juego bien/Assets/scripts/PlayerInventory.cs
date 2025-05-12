using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.SceneManagement;

public class PlayerInventory : MonoBehaviour
{
    public int NumberOfCosechas { get; private set; }
    public int NumberOfGasolina { get; private set; }
    public UnityEvent<PlayerInventory> OnCosechaCollected;
    public UnityEvent<PlayerInventory> OnGasolinaCollected;

    public GameControl gameControl;

    private Coroutine gasolinaTimer;

    private void Awake()
    {
        gameControl = FindObjectOfType<GameControl>();
    }

    private void Start()
    {
        // Suscribirse al evento de cambio de escena
        SceneManager.sceneLoaded += OnSceneLoaded;
        // Iniciar el temporizador de gasolina
        StartGasolinaTimer();
    }

    private void OnDestroy()
    {
        // Desuscribirse del evento al destruir el objeto
        SceneManager.sceneLoaded -= OnSceneLoaded;
    }

    private void OnSceneLoaded(Scene scene, LoadSceneMode mode)
    {
        // Actualizar el contador de cosechas al cambiar de nivel o escena
        ResetCosechasCounter();
    }

    public void CosechaCollected()
    {
        NumberOfCosechas++;
        OnCosechaCollected.Invoke(this);
        gameControl.checkGameOver(NumberOfCosechas);
    }

    public void GasolinaCollected()
    {
        NumberOfGasolina++;
        OnGasolinaCollected.Invoke(this);
    }

    public void ResetCosechasCounter()
    {
        // Establecer el contador de cosechas según la escena actual
        switch (SceneManager.GetActiveScene().name)
        {
            case "level 1":
                NumberOfCosechas = 0;
                break;
            case "level 2":
                NumberOfCosechas = 0; // Por ejemplo, en el nivel 2, ya se han recolectado 5 cosechas
                break;
            case "level 3":
                NumberOfCosechas = 0; // En el nivel 3, ya se han recolectado 10 cosechas
                break;
            default:
                NumberOfCosechas = 0; // Establecer un valor predeterminado
                break;
        }

        // Asegúrate de invocar el evento después de restablecer el contador
        OnCosechaCollected.Invoke(this);
    }



    private void StartGasolinaTimer()
    {
        gasolinaTimer = StartCoroutine(GasolinaCountdown());
    }

    private IEnumerator GasolinaCountdown()
    {
        float remainingTime = 20.0f; // Total de segundos para el temporizador

        while (remainingTime > 0)
        {
            yield return new WaitForSeconds(1.0f); // Espera 1 segundo
            remainingTime -= 1.0f; // Decrementa el tiempo restante
        }

        // Verifica si el temporizador llegó a cero sin interrupciones
        if (remainingTime < 0)
        {
            SceneManager.LoadScene("Perder"); // Carga la escena de perder
        }
    }


}








