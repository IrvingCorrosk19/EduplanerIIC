﻿namespace SchoolManager.ViewModels
{
    public class StudentAssignmentInputModel
    {
        public string Estudiante { get; set; } = string.Empty; // Email
        public string Nombre { get; set; } = string.Empty;     // Nombre del estudiante
        public string Apellido { get; set; } = string.Empty;   // Apellido del estudiante
        public string DocumentoId { get; set; } = string.Empty; // Documento de identidad
        public string FechaNacimiento { get; set; } = string.Empty; // Fecha de nacimiento
        public string Grado { get; set; } = string.Empty;      // Nombre del grado
        public string Grupo { get; set; } = string.Empty;      // Nombre del grupo
    }
}
