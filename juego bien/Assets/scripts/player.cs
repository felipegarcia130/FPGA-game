using UnityEngine;

public class Movement : MonoBehaviour
{
    [SerializeField] private float maxMoveSpeed = 7f;
    [SerializeField] private float acceleration = 0.5f;
    [SerializeField] private float deceleration = 1f;
    [SerializeField] private float maxRotateSpeed = 200f;
    [SerializeField] private GameInput gameInput;

    private float currentSpeed = 0f;
    private Rigidbody rb;
    private float currentTurnSpeed = 0f;
    private bool isReversing = false;

    public UIController controller;

    private void Awake()
    {
        rb = GetComponent<Rigidbody>();
    }

    void Update()
    {
        HandleMovementInput();
    }

    void HandleMovementInput()
    {
        Vector2 inputVector = gameInput.GetMovementVectorNormalized();
        bool isBraking = gameInput.IsBraking();

        // Update reversing state
        isReversing = inputVector.y < 0 || controller.Reverse == 1;

        // Handle acceleration, braking, and reversing
        if (isBraking || controller.Brake == 1)
        {
            currentSpeed = Mathf.MoveTowards(currentSpeed, 0, deceleration * Time.deltaTime);
        }
        else if (isReversing)
        {
            currentSpeed = Mathf.MoveTowards(currentSpeed, -maxMoveSpeed, acceleration * Time.deltaTime);
        }
        else if (inputVector.y > 0 || controller.Drive == 1)
        {
            currentSpeed = Mathf.MoveTowards(currentSpeed, maxMoveSpeed, acceleration * Time.deltaTime);
        }
        else
        {
            currentSpeed = Mathf.MoveTowards(currentSpeed, 0, acceleration * Time.deltaTime);
        }

        // Adjust turning speed based on horizontal input, keyboard, and UART commands
        if (Input.GetKey(KeyCode.A) || controller.Left == 1)
        {
            currentTurnSpeed = -maxRotateSpeed;
        }
        else if (Input.GetKey(KeyCode.D) || controller.Right == 1)
        {
            currentTurnSpeed = maxRotateSpeed;
        }
        else
        {
            currentTurnSpeed = 0;
        }
    }

    void FixedUpdate()
    {
        // Move the object forward or backward based on 'currentSpeed'
        rb.MovePosition(rb.position + transform.forward * currentSpeed * Time.fixedDeltaTime);

        // Rotate the object based on 'currentTurnSpeed'
        if (currentTurnSpeed != 0)
        {
            rb.MoveRotation(rb.rotation * Quaternion.Euler(0, currentTurnSpeed * Time.fixedDeltaTime, 0));
        }
    }
}