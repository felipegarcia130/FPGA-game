using System.Collections;
using UnityEngine;

public class Gasolina : MonoBehaviour
{
    public delegate void OnGasolinaCollected(); // Delegate for cosecha collected event
    public static event OnGasolinaCollected gasolinaCollectedEvent;

    private void OnTriggerEnter(Collider other)
    {
        PlayerInventory playerInventory = other.GetComponent<PlayerInventory>();

        if (playerInventory != null)
        {
            playerInventory.GasolinaCollected();
            gameObject.SetActive(false);
            Debug.Log("Cosecha collected and deactivated.");

            // Trigger event when cosecha is collected
            gasolinaCollectedEvent?.Invoke();

            Invoke("ReactivateObject", 5); // Use Invoke to delay the call to ReactivateObject
        }
    }

    private void ReactivateObject()
    {
        Debug.Log("ReactivateObject called. Reactivating object.");
        gameObject.SetActive(true); // Reactivate the game object
    }
}
