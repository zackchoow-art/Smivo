/**
 * Dialog for creating or editing a college (school).
 * Uses React Hook Form + Zod for validation.
 */
import { useEffect } from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { X, Loader2 } from 'lucide-react';
import { z } from 'zod';
import type { College } from '@/types';

const collegeSchema = z.object({
  name: z.string().min(2, 'Name must be at least 2 characters'),
  slug: z.string().min(2, 'Slug must be at least 2 characters')
    .regex(/^[a-z0-9-]+$/, 'Slug must be lowercase alphanumeric with dashes'),
  email_domain: z.string().min(3, 'Email domain required')
    .regex(/^[a-z0-9.-]+\.[a-z]{2,}$/, 'Must be a valid domain (e.g. smith.edu)'),
  primary_color: z.string().nullable().optional(),
  website_url: z.string().nullable().optional(),
  description: z.string().nullable().optional(),
  student_count: z.preprocess((val) => {
    if (val === '' || val === null || val === undefined || Number.isNaN(val)) return null;
    return Number(val);
  }, z.number().int().positive().nullable().optional()),
  address: z.string().nullable().optional(),
  city: z.string().nullable().optional(),
  state: z.string().nullable().optional(),
  zip_code: z.string().nullable().optional(),
});

type CollegeFormData = z.infer<typeof collegeSchema>;

interface CollegeDialogProps {
  college: College | null;
  onClose: () => void;
  onSubmit: (data: CollegeFormData) => Promise<void>;
  isSubmitting: boolean;
}

export function CollegeDialog({ college, onClose, onSubmit, isSubmitting }: CollegeDialogProps) {
  const isEditing = !!college;

  // HACK: zodResolver type inference breaks with Zod v4 + RHF v7
  // — safe because schema validation still runs correctly at runtime
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const { register, handleSubmit, reset, formState: { errors } } = useForm<CollegeFormData>({
    resolver: zodResolver(collegeSchema) as any,
    defaultValues: {
      name: college?.name ?? '',
      slug: college?.slug ?? '',
      email_domain: college?.email_domain ?? '',
      primary_color: college?.primary_color ?? '',
      website_url: college?.website_url ?? '',
      description: college?.description ?? '',
      student_count: college?.student_count ?? undefined,
      address: college?.address ?? '',
      city: college?.city ?? '',
      state: college?.state ?? '',
      zip_code: college?.zip_code ?? '',
    },
  });

  useEffect(() => {
    if (college) {
      reset({
        name: college.name,
        slug: college.slug,
        email_domain: college.email_domain,
        primary_color: college.primary_color ?? '',
        website_url: college.website_url ?? '',
        description: college.description ?? '',
        student_count: college.student_count ?? undefined,
        address: college.address ?? '',
        city: college.city ?? '',
        state: college.state ?? '',
        zip_code: college.zip_code ?? '',
      });
    }
  }, [college, reset]);

  const onFormSubmit = async (data: CollegeFormData) => {
    // Clean up empty strings to null
    const cleaned = {
      ...data,
      primary_color: data.primary_color || null,
      website_url: data.website_url || null,
      description: data.description || null,
      student_count: data.student_count || null,
      address: data.address || null,
      city: data.city || null,
      state: data.state || null,
      zip_code: data.zip_code || null,
    };
    await onSubmit(cleaned);
  };

  return (
    <div className="cdialog-overlay" onClick={onClose}>
      <div className="cdialog" onClick={(e) => e.stopPropagation()}>
        <div className="cdialog-header">
          <h2>{isEditing ? 'Edit School' : 'Add New School'}</h2>
          <button className="cdialog-close" onClick={onClose}>
            <X size={18} />
          </button>
        </div>

        <form onSubmit={handleSubmit(onFormSubmit)} className="cdialog-body">
          <div className="cdialog-grid">
            {/* Name */}
            <div className="cdialog-field full">
              <label>School Name *</label>
              <input {...register('name')} placeholder="Smith College" />
              {errors.name && <span className="cdialog-error">{errors.name.message}</span>}
            </div>

            {/* Slug */}
            <div className="cdialog-field">
              <label>Slug *</label>
              <input {...register('slug')} placeholder="smith" readOnly={isEditing} className={isEditing ? 'readonly' : ''} />
              {errors.slug && <span className="cdialog-error">{errors.slug.message}</span>}
            </div>

            {/* Email Domain */}
            <div className="cdialog-field">
              <label>Email Domain *</label>
              <input {...register('email_domain')} placeholder="smith.edu" />
              {errors.email_domain && <span className="cdialog-error">{errors.email_domain.message}</span>}
            </div>

            {/* Student Count */}
            <div className="cdialog-field">
              <label>Student Count</label>
              <input type="number" {...register('student_count', { valueAsNumber: true })} placeholder="2500" />
            </div>

            {/* Primary Color */}
            <div className="cdialog-field">
              <label>Primary Color</label>
              <input {...register('primary_color')} placeholder="#004990" />
            </div>

            {/* Website */}
            <div className="cdialog-field full">
              <label>Website URL</label>
              <input {...register('website_url')} placeholder="https://www.smith.edu" />
            </div>

            {/* Address */}
            <div className="cdialog-field full">
              <label>Address</label>
              <input {...register('address')} placeholder="1 Chapin Way" />
            </div>

            <div className="cdialog-field">
              <label>City</label>
              <input {...register('city')} placeholder="Northampton" />
            </div>

            <div className="cdialog-field">
              <label>State</label>
              <input {...register('state')} placeholder="MA" />
            </div>

            <div className="cdialog-field">
              <label>Zip Code</label>
              <input {...register('zip_code')} placeholder="01063" />
            </div>

            {/* Description */}
            <div className="cdialog-field full">
              <label>Description</label>
              <textarea {...register('description')} rows={3} placeholder="Brief school description..." />
            </div>
          </div>

          <div className="cdialog-actions">
            <button type="button" className="cdialog-btn-cancel" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="cdialog-btn-submit" disabled={isSubmitting}>
              {isSubmitting && <Loader2 size={14} className="spin" />}
              {isEditing ? 'Save Changes' : 'Create School'}
            </button>
          </div>
        </form>
      </div>

      <style>{`
        .cdialog-overlay {
          position: fixed;
          inset: 0;
          background: rgba(0, 0, 0, 0.5);
          display: flex;
          align-items: center;
          justify-content: center;
          z-index: 1000;
          padding: 24px;
        }

        .cdialog {
          background: var(--color-bg-primary);
          border-radius: var(--radius-lg);
          box-shadow: var(--shadow-modal);
          width: 100%;
          max-width: 560px;
          max-height: 85vh;
          display: flex;
          flex-direction: column;
        }

        .cdialog-header {
          display: flex;
          align-items: center;
          justify-content: space-between;
          padding: 16px 20px;
          border-bottom: 1px solid var(--color-border-light);
        }

        .cdialog-header h2 {
          font-size: 16px;
          font-weight: 600;
          color: var(--color-text-primary);
        }

        .cdialog-close {
          background: none;
          border: none;
          cursor: pointer;
          padding: 4px;
          color: var(--color-text-tertiary);
          border-radius: var(--radius-sm);
        }

        .cdialog-close:hover {
          background: var(--color-bg-tertiary);
          color: var(--color-text-primary);
        }

        .cdialog-body {
          padding: 20px;
          overflow-y: auto;
        }

        .cdialog-grid {
          display: grid;
          grid-template-columns: 1fr 1fr;
          gap: 12px;
        }

        .cdialog-field {
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .cdialog-field.full {
          grid-column: 1 / -1;
        }

        .cdialog-field label {
          font-size: 11px;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.04em;
          color: var(--color-text-tertiary);
        }

        .cdialog-field input,
        .cdialog-field textarea {
          padding: 8px 10px;
          font-size: 13px;
          border: 1px solid var(--color-border);
          border-radius: var(--radius-sm);
          background: var(--color-bg-secondary);
          color: var(--color-text-primary);
          outline: none;
          font-family: var(--font-sans);
        }

        .cdialog-field input:focus,
        .cdialog-field textarea:focus {
          border-color: var(--color-border-focus);
        }

        .cdialog-field input:disabled,
        .cdialog-field input.readonly {
          opacity: 0.5;
          cursor: not-allowed;
        }

        .cdialog-error {
          font-size: 11px;
          color: var(--color-danger);
        }

        .cdialog-actions {
          display: flex;
          justify-content: flex-end;
          gap: 8px;
          padding-top: 16px;
          margin-top: 8px;
          border-top: 1px solid var(--color-border-light);
        }

        .cdialog-btn-cancel,
        .cdialog-btn-submit {
          display: flex;
          align-items: center;
          gap: 6px;
          padding: 8px 16px;
          font-size: 13px;
          border-radius: var(--radius-md);
          cursor: pointer;
          border: 1px solid var(--color-border);
        }

        .cdialog-btn-cancel {
          background: var(--color-bg-primary);
          color: var(--color-text-secondary);
        }

        .cdialog-btn-submit {
          background: var(--color-info);
          color: white;
          border-color: var(--color-info);
        }

        .cdialog-btn-submit:disabled {
          opacity: 0.6;
          cursor: not-allowed;
        }

        .spin {
          animation: spin 1s linear infinite;
        }

        @keyframes spin {
          to { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
}
