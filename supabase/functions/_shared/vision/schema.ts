// src/vision/schema.ts
// Schema de validação para contexto visual usando Zod

import { z } from 'https://deno.land/x/zod@v3.22.4/mod.ts';

export const VisionContextSchema = z.object({
  schema_version: z.string().default('1.0'),
  detected_persons: z.object({
    count: z.number().int().min(0).max(10).default(0)
  }),
  objects: z.array(z.object({
    name: z.string().min(1).max(50),
    confidence: z.number().min(0).max(1),
    source: z.literal('vision')
  })).default([]),
  actions: z.array(z.object({
    name: z.string().min(1).max(50),
    confidence: z.number().min(0).max(1),
    source: z.literal('vision')
  })).default([]),
  places: z.array(z.object({
    name: z.string().min(1).max(50),
    confidence: z.number().min(0).max(1),
    source: z.literal('vision')
  })).default([]),
  colors: z.array(z.string().min(1).max(30)).default([]),
  ocr_text: z.string().default(''),
  notable_details: z.array(z.string().min(1).max(100)).default([]),
  confidence_overall: z.number().min(0).max(1).default(0)
});

/**
 * Valida e normaliza dados de contexto visual
 */
export function validateVisionContext(data: unknown): {
  success: boolean;
  data?: z.infer<typeof VisionContextSchema>;
  errors?: z.ZodError;
} {
  try {
    const validatedData = VisionContextSchema.parse(data);
    return {
      success: true,
      data: validatedData
    };
  } catch (error) {
    if (error instanceof z.ZodError) {
      return {
        success: false,
        errors: error
      };
    }
    throw error;
  }
}

/**
 * Converte erros de validação para formato legível
 */
export function formatValidationErrors(errors: z.ZodError): string[] {
  return errors.errors.map(err => {
    const path = err.path.join('.');
    return `${path}: ${err.message}`;
  });
}
