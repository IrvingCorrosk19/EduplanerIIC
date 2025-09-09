using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SchoolManager.Migrations
{
    /// <inheritdoc />
    public partial class FixCounselorAssignmentConstraintsManual : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Ejecutar SQL personalizado para corregir constraints
            migrationBuilder.Sql(@"
                DO $$
                BEGIN
                    IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'counselor_assignments') THEN
                        -- Eliminar constraints problemáticos si existen
                        DROP INDEX IF EXISTS counselor_assignments_school_grade_key;
                        DROP INDEX IF EXISTS counselor_assignments_school_group_key;
                        
                        -- Crear el constraint correcto para combinación grado-grupo única
                        CREATE UNIQUE INDEX IF NOT EXISTS counselor_assignments_school_grade_group_key 
                        ON counselor_assignments (school_id, grade_id, group_id) 
                        WHERE grade_id IS NOT NULL AND group_id IS NOT NULL;
                        
                        RAISE NOTICE 'Constraints de counselor_assignments corregidos exitosamente';
                    ELSE
                        RAISE NOTICE 'La tabla counselor_assignments no existe aún';
                    END IF;
                END $$;
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "counselor_assignments_school_grade_group_key",
                table: "counselor_assignments");

            migrationBuilder.CreateIndex(
                name: "counselor_assignments_school_grade_key",
                table: "counselor_assignments",
                columns: new[] { "school_id", "grade_id" },
                unique: true,
                filter: "grade_id IS NOT NULL");

            migrationBuilder.CreateIndex(
                name: "counselor_assignments_school_group_key",
                table: "counselor_assignments",
                columns: new[] { "school_id", "group_id" },
                unique: true,
                filter: "group_id IS NOT NULL");
        }
    }
}
