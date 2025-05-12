using System.Collections;
using UnityEngine;

public class Cosecha : MonoBehaviour
{
    public delegate void OnCosechaCollected(); // Delegate for cosecha collected event
    public static event OnCosechaCollected cosechaCollectedEvent;

    private void OnTriggerEnter(Collider other)
    {
        PlayerInventory playerInventory = other.GetComponent<PlayerInventory>();

        if (playerInventory != null)
        {
            playerInventory.CosechaCollected();
            gameObject.SetActive(false);
            Debug.Log("Cosecha collected and deactivated.");

            // Trigger event when cosecha is collected
            cosechaCollectedEvent?.Invoke();

            Invoke("ReactivateObject", 5); // Use Invoke to delay the call to ReactivateObject
        }
    }

    private void ReactivateObject()
    {
        Debug.Log("ReactivateObject called. Reactivating object.");
        gameObject.SetActive(true); // Reactivate the game object
    }
}

