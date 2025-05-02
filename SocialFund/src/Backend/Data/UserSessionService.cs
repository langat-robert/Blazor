public class UserSessionService
{
    public string? UserID { get; private set; }

    public void SetUserID(string userId)
    {
        UserID = userId;
    }

    public string? GetUserID()
    {
        return UserID;
    }
}