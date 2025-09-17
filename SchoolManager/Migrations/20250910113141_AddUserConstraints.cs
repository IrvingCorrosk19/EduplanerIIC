using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SchoolManager.Migrations
{
    /// <inheritdoc />
    public partial class AddUserConstraints : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Agregar constraint para validar roles válidos
            migrationBuilder.Sql(@"
                ALTER TABLE users 
                ADD CONSTRAINT users_role_check 
                CHECK (role IN ('superadmin', 'admin', 'director', 'teacher', 'parent', 'student', 'estudiante'));
            ");

            // Agregar constraint para validar status válidos
            migrationBuilder.Sql(@"
                ALTER TABLE users 
                ADD CONSTRAINT users_status_check 
                CHECK (status IN ('active', 'inactive'));
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Eliminar constraints
            migrationBuilder.Sql("ALTER TABLE users DROP CONSTRAINT IF EXISTS users_role_check;");
            migrationBuilder.Sql("ALTER TABLE users DROP CONSTRAINT IF EXISTS users_status_check;");
        }
    }
}
