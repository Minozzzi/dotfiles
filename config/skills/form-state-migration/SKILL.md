# Form State Migration Skill

Guidelines for refactoring legacy React form modals to server actions with `useFormState` and Zod validation in `imowiz-frontend`.

## Key Principles
1. **Zod Validation**: Validate incoming FormData strings using Zod schemas (`@imowiz/utils/validate-form-data`).
2. **Custom Hook Extraction**: Encapsulate `useFormState`, search comboboxes (400ms debounce), default values, and data fetches into custom hooks (`use-<domain>-form.ts`).
3. **Dynamic Array Fields**: Use local React `useState` solely for rendering row addition/removal. Bind inputs via dot-notation `name` attributes (e.g., `stages.${index}.name`).
4. **Radix Checkbox Handling**: Unchecked checkboxes are omitted from `FormData`. Coerce them in the Zod schema:
   ```typescript
   z.coerce.boolean().optional().default(false)
   ```
5. **Pure JSX Dialogs**: Dialog components destructure state and handles from the hook and render native/Radix form controls.
