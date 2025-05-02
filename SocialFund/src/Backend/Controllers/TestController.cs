using Microsoft.AspNetCore.Mvc;
using Backend.Data;

namespace Backend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TestController : ControllerBase
    {
        private readonly SocialFundDbContext _context;

        public TestController(SocialFundDbContext context)
        {
            _context = context;
        }

        [HttpGet("test-connection")]
        public IActionResult TestConnection()
        {
            try
            {
                if (_context.Database.CanConnect())
                {
                    return Ok("Database connection is successful.");
                }
                else
                {
                    return StatusCode(500, "Database connection failed.");
                }
            }
            catch (Exception ex)
            {
                return StatusCode(500, $"Database connection failed: {ex.Message}");
            }
        }
    }
}