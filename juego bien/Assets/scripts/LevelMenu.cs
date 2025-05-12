using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class LevelMenu : MonoBehaviour
{
    public void OpenLevel(int levelid)
    {
        string levelname = "level " + levelid;
        SceneManager.LoadScene(levelname);
    }
}
