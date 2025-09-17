using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SchoolManager.Migrations
{
    /// <inheritdoc />
    public partial class AddOrientationReportsTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "orientation_reports",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
                    school_id = table.Column<Guid>(type: "uuid", nullable: true),
                    student_id = table.Column<Guid>(type: "uuid", nullable: true),
                    teacher_id = table.Column<Guid>(type: "uuid", nullable: true),
                    date = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    report_type = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: true),
                    description = table.Column<string>(type: "text", nullable: true),
                    status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "CURRENT_TIMESTAMP"),
                    created_by = table.Column<Guid>(type: "uuid", nullable: true),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    updated_by = table.Column<Guid>(type: "uuid", nullable: true),
                    subject_id = table.Column<Guid>(type: "uuid", nullable: true),
                    group_id = table.Column<Guid>(type: "uuid", nullable: true),
                    grade_level_id = table.Column<Guid>(type: "uuid", nullable: true),
                    category = table.Column<string>(type: "text", nullable: true),
                    documents = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_orientation_reports", x => x.id);
                    table.ForeignKey(
                        name: "FK_orientation_reports_schools_school_id",
                        column: x => x.school_id,
                        principalTable: "schools",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "FK_orientation_reports_users_created_by",
                        column: x => x.created_by,
                        principalTable: "users",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "FK_orientation_reports_users_updated_by",
                        column: x => x.updated_by,
                        principalTable: "users",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "orientation_reports_grade_level_id_fkey",
                        column: x => x.grade_level_id,
                        principalTable: "grade_levels",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "orientation_reports_group_id_fkey",
                        column: x => x.group_id,
                        principalTable: "groups",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "orientation_reports_student_id_fkey",
                        column: x => x.student_id,
                        principalTable: "users",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "orientation_reports_subject_id_fkey",
                        column: x => x.subject_id,
                        principalTable: "subjects",
                        principalColumn: "id");
                    table.ForeignKey(
                        name: "orientation_reports_teacher_id_fkey",
                        column: x => x.teacher_id,
                        principalTable: "users",
                        principalColumn: "id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_orientation_reports_created_by",
                table: "orientation_reports",
                column: "created_by");

            migrationBuilder.CreateIndex(
                name: "IX_orientation_reports_grade_level_id",
                table: "orientation_reports",
                column: "grade_level_id");

            migrationBuilder.CreateIndex(
                name: "IX_orientation_reports_group_id",
                table: "orientation_reports",
                column: "group_id");

            migrationBuilder.CreateIndex(
                name: "IX_orientation_reports_school_id",
                table: "orientation_reports",
                column: "school_id");

            migrationBuilder.CreateIndex(
                name: "IX_orientation_reports_student_id",
                table: "orientation_reports",
                column: "student_id");

            migrationBuilder.CreateIndex(
                name: "IX_orientation_reports_subject_id",
                table: "orientation_reports",
                column: "subject_id");

            migrationBuilder.CreateIndex(
                name: "IX_orientation_reports_teacher_id",
                table: "orientation_reports",
                column: "teacher_id");

            migrationBuilder.CreateIndex(
                name: "IX_orientation_reports_updated_by",
                table: "orientation_reports",
                column: "updated_by");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "orientation_reports");
        }
    }
}
