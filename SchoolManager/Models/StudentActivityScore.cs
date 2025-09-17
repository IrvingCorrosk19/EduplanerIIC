﻿using System;
using System.Collections.Generic;

namespace SchoolManager.Models;

public partial class StudentActivityScore
{
    public Guid Id { get; set; }

    public Guid? SchoolId { get; set; }

    public Guid StudentId { get; set; }

    public Guid ActivityId { get; set; }

    public decimal? Score { get; set; }

    public DateTime CreatedAt { get; set; }

    public Guid? CreatedBy { get; set; }

    public DateTime? UpdatedAt { get; set; }

    public Guid? UpdatedBy { get; set; }

    public virtual Activity Activity { get; set; } = null!;

    public virtual School? School { get; set; }

    public virtual User Student { get; set; } = null!;

    public virtual User? CreatedByUser { get; set; }

    public virtual User? UpdatedByUser { get; set; }
}
