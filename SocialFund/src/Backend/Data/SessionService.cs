using Microsoft.AspNetCore.Http;

public class SessionService
{
    private readonly IHttpContextAccessor _httpContextAccessor;

    public SessionService(IHttpContextAccessor httpContextAccessor)
    {
        _httpContextAccessor = httpContextAccessor;
    }

    public void Set(string key, string value)
    {
        _httpContextAccessor.HttpContext?.Session.SetString(key, value);
    }

    public string? Get(string key)
    {
        return _httpContextAccessor.HttpContext?.Session.GetString(key);
    }
}