using UnityEngine;

/// <summary>
/// Controls the isometric camera for Florence city view
/// Pan with WASD/Arrow Keys, Zoom with Mouse Wheel
/// Right Click + Drag for alternative panning
/// </summary>
public class IsometricCameraController : MonoBehaviour
{
    public static IsometricCameraController Instance { get; private set; }

    [Header("Pan Settings")]
    [SerializeField] private float panSpeed = 10f;
    [SerializeField] private float panSmoothTime = 0.1f;
    [SerializeField] private bool invertPan = false;

    [Header("Zoom Settings")]
    [SerializeField] private float zoomSpeed = 5f;
    [SerializeField] private float minZoom = 3f;
    [SerializeField] private float maxZoom = 15f;
    [SerializeField] private float zoomSmoothTime = 0.1f;

    [Header("Boundaries")]
    [SerializeField] private bool useBoundaries = true;
    [SerializeField] private Vector2 minBounds = new Vector2(-20f, -15f);
    [SerializeField] private Vector2 maxBounds = new Vector2(20f, 15f);

    [Header("Focus Settings")]
    [SerializeField] private float focusDuration = 1f;
    [SerializeField] private AnimationCurve focusCurve = AnimationCurve.EaseInOut(0, 0, 1, 1);

    private Camera mainCamera;
    private Vector3 targetPosition;
    private float targetZoom;
    private Vector3 velocity = Vector3.zero;
    private float zoomVelocity = 0f;

    private bool isRightMouseDragging = false;
    private Vector3 lastMousePosition;
    private bool isFocusing = false;

    private void Awake()
    {
        if (Instance == null)
        {
            Instance = this;
        }
        else
        {
            Destroy(gameObject);
        }

        mainCamera = GetComponent<Camera>();
        if (mainCamera == null)
        {
            mainCamera = Camera.main;
        }
    }

    private void Start()
    {
        targetPosition = transform.position;
        targetZoom = mainCamera.orthographicSize;
    }

    private void Update()
    {
        if (isFocusing) return;

        HandleKeyboardPan();
        HandleMousePan();
        HandleZoom();
        ApplyMovement();
    }

    private void HandleKeyboardPan()
    {
        float horizontal = Input.GetAxisRaw("Horizontal");
        float vertical = Input.GetAxisRaw("Vertical");

        if (horizontal != 0 || vertical != 0)
        {
            Vector3 direction = new Vector3(horizontal, vertical, 0f).normalized;

            if (invertPan)
            {
                direction = -direction;
            }

            // Adjust for isometric view (diagonal movement)
            Vector3 isometricDirection = new Vector3(
                direction.x + direction.y,
                (direction.y - direction.x) * 0.5f,
                0f
            ).normalized;

            targetPosition += isometricDirection * panSpeed * Time.deltaTime;
        }
    }

    private void HandleMousePan()
    {
        // Right click drag panning
        if (Input.GetMouseButtonDown(1))
        {
            isRightMouseDragging = true;
            lastMousePosition = Input.mousePosition;
        }

        if (Input.GetMouseButtonUp(1))
        {
            isRightMouseDragging = false;
        }

        if (isRightMouseDragging)
        {
            Vector3 delta = Input.mousePosition - lastMousePosition;
            Vector3 worldDelta = mainCamera.ScreenToWorldPoint(Vector3.zero) -
                                 mainCamera.ScreenToWorldPoint(delta);

            targetPosition += new Vector3(worldDelta.x, worldDelta.y, 0f);
            lastMousePosition = Input.mousePosition;
        }
    }

    private void HandleZoom()
    {
        float scroll = Input.GetAxis("Mouse ScrollWheel");

        if (scroll != 0)
        {
            targetZoom -= scroll * zoomSpeed;
            targetZoom = Mathf.Clamp(targetZoom, minZoom, maxZoom);
        }
    }

    private void ApplyMovement()
    {
        // Clamp target position to boundaries
        if (useBoundaries)
        {
            targetPosition.x = Mathf.Clamp(targetPosition.x, minBounds.x, maxBounds.x);
            targetPosition.y = Mathf.Clamp(targetPosition.y, minBounds.y, maxBounds.y);
        }

        // Smooth pan
        Vector3 newPosition = Vector3.SmoothDamp(
            transform.position,
            new Vector3(targetPosition.x, targetPosition.y, transform.position.z),
            ref velocity,
            panSmoothTime
        );
        transform.position = newPosition;

        // Smooth zoom
        float newZoom = Mathf.SmoothDamp(
            mainCamera.orthographicSize,
            targetZoom,
            ref zoomVelocity,
            zoomSmoothTime
        );
        mainCamera.orthographicSize = newZoom;
    }

    /// <summary>
    /// Focus camera on a specific position (used when building is placed)
    /// </summary>
    public void FocusOn(Vector3 worldPosition, float duration = -1f)
    {
        if (duration < 0) duration = focusDuration;
        StartCoroutine(FocusCoroutine(worldPosition, duration));
    }

    private System.Collections.IEnumerator FocusCoroutine(Vector3 worldPosition, float duration)
    {
        isFocusing = true;

        Vector3 startPosition = transform.position;
        Vector3 endPosition = new Vector3(worldPosition.x, worldPosition.y, transform.position.z);

        float elapsed = 0f;

        while (elapsed < duration)
        {
            elapsed += Time.deltaTime;
            float t = focusCurve.Evaluate(elapsed / duration);

            transform.position = Vector3.Lerp(startPosition, endPosition, t);

            yield return null;
        }

        transform.position = endPosition;
        targetPosition = endPosition;
        isFocusing = false;
    }

    /// <summary>
    /// Set camera boundaries dynamically
    /// </summary>
    public void SetBoundaries(Vector2 min, Vector2 max)
    {
        minBounds = min;
        maxBounds = max;
    }

    /// <summary>
    /// Instantly move camera to position
    /// </summary>
    public void SetPosition(Vector3 position)
    {
        transform.position = new Vector3(position.x, position.y, transform.position.z);
        targetPosition = transform.position;
    }

    /// <summary>
    /// Set zoom level
    /// </summary>
    public void SetZoom(float zoom)
    {
        targetZoom = Mathf.Clamp(zoom, minZoom, maxZoom);
        mainCamera.orthographicSize = targetZoom;
    }
}
