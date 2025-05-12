
using UnityEngine;

public class PlayerCollision : MonoBehaviour
{
    void OnCollisionEnter(Collision collisionInfo)
    {
            if (collisionInfo.collider.tag == "pared")
        {
            Debug.Log("we hit the tower");
        }
    }
}
