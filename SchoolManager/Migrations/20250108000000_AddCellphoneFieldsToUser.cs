using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SchoolManager.Migrations
{
    /// <inheritdoc />
    public partial class AddCellphoneFieldsToUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Las columnas ya existen en la base de datos, solo necesitamos registrar la migración
            // No ejecutamos SQL porque las columnas ya están creadas manualmente
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Si necesitamos revertir, eliminamos las columnas
            migrationBuilder.DropColumn(
                name: "cellphone_primary",
                table: "users");

            migrationBuilder.DropColumn(
                name: "cellphone_secondary",
                table: "users");
        }
    }
}