using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SchoolManager.Migrations
{
    /// <inheritdoc />
    public partial class AddDocumentsToDisciplineReport : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "category",
                table: "discipline_reports",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "documents",
                table: "discipline_reports",
                type: "text",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "category",
                table: "discipline_reports");

            migrationBuilder.DropColumn(
                name: "documents",
                table: "discipline_reports");
        }
    }
}
