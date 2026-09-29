---
name: react-pdf-styling
description: "Rules for styling @react-pdf/renderer components, specifically avoiding nested style arrays to prevent TypeScript errors."
---

When applying dynamic or conditional styles in `@react-pdf/renderer`, never pass an array of arrays to the `style` prop. TypeScript will throw `Type 'Style[]' is not assignable to type 'Style'` because `react-pdf` does not automatically flatten nested style arrays like React Native does. 

Always spread the base styles and conditional styles into a flat object instead.

**Bad:**
```tsx
const cellStyle = [styles.tableCell, showDiscount ? { width: "9%" } : { width: "11%" }];
// This will fail if you later do:
<Text style={[cellStyle, styles.tableHeaderCell]}>...</Text> // Array of arrays!
```

**Good:**
```tsx
const cellStyle = {
  ...styles.tableCell,
  ...(showDiscount ? { width: "9%" } : { width: "11%" })
};
<Text style={[cellStyle, styles.tableHeaderCell]}>...</Text>
```
