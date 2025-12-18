# Current Task - Agent 1 (Backend Core)

## Status

🚀 IN PROGRESS

## Task Description

Implement the REST API endpoints for the Content module. This includes Views and Serializers for **Topics**, **BlogPosts**, and **SocialPosts**.

## Requirements

1. **Architecture**: Use the existing "Service Layer" pattern.
    - Views should be thin (serialization + permission checks).
    - Read logic -> `selectors.py`
    - Write logic -> `services.py`
2. **Endpoints to Implement**:
    - `Topic`: List, Create, Update, Approve, Reject
    - `BlogPost`: List, Create, Update, Approve, Reject, Publish
    - `SocialPost`: List, Create, Update, Approve, Reject, Publish
3. **Validation**: Use Django Rest Framework serializers.
4. **Permissions**: Ensure user is authenticated.

## Provided Files

- `backend/apps/content/models.py` (Data structure)
- `backend/apps/content/services.py` (Write logic)
- `backend/apps/content/selectors.py` (Read logic)
- `backend/apps/content/urls.py` (Routing)

## Expected Output

1. `backend/apps/content/serializers.py` containing all necessary serializers.
2. `backend/apps/content/views.py` containing ViewSets.
3. `backend/apps/content/urls.py` updated with routes.
4. `backend/tests/integration/test_content_api.py` verifying the endpoints.

## Notes

- Zero Tolerance: No mock data, no TODOs.
- Ensure all imports use absolute paths (e.g., `from apps.content.models import ...`)
