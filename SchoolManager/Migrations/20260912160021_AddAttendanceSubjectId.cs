using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SchoolManager.Migrations
{
    /// <inheritdoc />
    public partial class AddAttendanceSubjectId : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "subject_id",
                table: "attendance",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Attendance_Student_Subject_Group_Grade_Date",
                table: "attendance",
                columns: new[] { "student_id", "subject_id", "group_id", "grade_id", "date" });

            migrationBuilder.CreateIndex(
                name: "IX_Attendance_SubjectId",
                table: "attendance",
                column: "subject_id");

            migrationBuilder.AddForeignKey(
                name: "attendance_subject_id_fkey",
                table: "attendance",
                column: "subject_id",
                principalTable: "subjects",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);

            // Respaldo reversible: estado previo al backfill (subject_id nulo).
            migrationBuilder.Sql("""
                CREATE TABLE IF NOT EXISTS attendance_subject_backfill_20260912 AS
                SELECT
                    a.id,
                    a.student_id,
                    a.teacher_id,
                    a.group_id,
                    a.grade_id,
                    a.date,
                    a.status,
                    a.subject_id,
                    a.trimester_id,
                    a.academic_year_id,
                    a.school_id,
                    a.created_at,
                    a.updated_at
                FROM attendance a
                WHERE a.subject_id IS NULL;
                """);

            // Solo asocia materia cuando el docente tiene exactamente una materia en ese grupo y grado.
            migrationBuilder.Sql("""
                SET statement_timeout = '600000';
                CREATE TABLE IF NOT EXISTS attendance_unambiguous_teacher_subject_20260912 AS
                SELECT
                    ta.teacher_id,
                    sa.group_id,
                    sa.grade_level_id,
                    (ARRAY_AGG(sa.subject_id))[1] AS subject_id
                FROM teacher_assignments AS ta
                INNER JOIN subject_assignments AS sa
                    ON sa.id = ta.subject_assignment_id
                GROUP BY ta.teacher_id, sa.group_id, sa.grade_level_id
                HAVING COUNT(DISTINCT sa.subject_id) = 1;
                CREATE INDEX IF NOT EXISTS ix_unambiguous_teacher_subject_20260912
                    ON attendance_unambiguous_teacher_subject_20260912 (teacher_id, group_id, grade_level_id);
                UPDATE attendance AS a
                SET subject_id = u.subject_id
                FROM attendance_unambiguous_teacher_subject_20260912 AS u
                WHERE a.subject_id IS NULL
                  AND a.teacher_id = u.teacher_id
                  AND a.group_id = u.group_id
                  AND a.grade_id = u.grade_level_id;
                """);

            // Inventario de filas que no pudieron asociarse de forma inequívoca.
            migrationBuilder.Sql("""
                CREATE TABLE IF NOT EXISTS attendance_unresolved_subject_inventory_20260912 AS
                SELECT
                    a.id,
                    a.student_id,
                    a.teacher_id,
                    a.group_id,
                    a.grade_id,
                    a.date,
                    a.status,
                    a.school_id,
                    a.academic_year_id
                FROM attendance AS a
                WHERE a.subject_id IS NULL;
                """);

            // Duplicados históricos de la identidad funcional. No se eliminan.
            // Por eso no se crea índice UNIQUE: la migración fallaría.
            migrationBuilder.Sql("""
                CREATE TABLE IF NOT EXISTS attendance_duplicate_identity_inventory_20260912 AS
                SELECT
                    student_id,
                    subject_id,
                    group_id,
                    grade_id,
                    date,
                    COUNT(*) AS row_count
                FROM attendance
                WHERE subject_id IS NOT NULL
                  AND student_id IS NOT NULL
                  AND group_id IS NOT NULL
                  AND grade_id IS NOT NULL
                GROUP BY student_id, subject_id, group_id, grade_id, date
                HAVING COUNT(*) > 1;
                """);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "attendance_subject_id_fkey",
                table: "attendance");

            migrationBuilder.DropIndex(
                name: "IX_Attendance_Student_Subject_Group_Grade_Date",
                table: "attendance");

            migrationBuilder.DropIndex(
                name: "IX_Attendance_SubjectId",
                table: "attendance");

            migrationBuilder.DropColumn(
                name: "subject_id",
                table: "attendance");
        }
    }
}
