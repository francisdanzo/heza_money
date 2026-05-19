# 🏠 Home Screen — Design System Overrides

**Screen:** Accueil (Home)  
**Priority:** CRITICAL (main dashboard, user entry point)  
**Glassmorphism:** YES (heavy use of frosted glass cards)  
**Light/Dark Theme:** Both fully supported

---

## 📐 LAYOUT STRUCTURE

### Hero Section (Top)
- **Gradient Background** → Use LinearGradient from primary to light shade
  - Light: `#F9FAFB` → `#FFFFFF`
  - Dark: `#0F172A` → `#1A2847`
- **Height:** 140px
- **Content:** Greeting "Muraho, [Prénom]" + Avatar with initials

### Main Content (Scrollable)
1. **Available Balance Card** (glassmorphic, prominent)
2. **Quick Actions** (4 buttons in 2×2 grid)
3. **Stat Cards** (side-by-side: Month Expenses + Savings)
4. **50/30/20 Rule Bars** (3 stacked progress bars)
5. **Daily Lesson Card** (green background, minimal glass effect)
6. **Empty Space** (for bottom nav)

---

## 🎨 COMPONENT OVERRIDES

### Available Balance Card (HERO)

**Design Goal:** Most important card, takes up top 1/3 of scroll area

```dart
GlassCard(
  blur: 20, // Stronger blur for hero prominence
  opacity: 0.8, // Slightly more opaque (light mode)
  padding: EdgeInsets.all(20), // Generous padding
  borderRadius: BorderRadius.circular(20), // Larger radius for importance
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Solde Disponible', style: bodyLarge.copyWith(color: textSecondary)),
      SizedBox(height: 8),
      Text(
        '${formatCurrency(availableBalance)}', // e.g., "450 000 BIF"
        style: displayLarge.copyWith(
          color: Color(0xFF0F6E56), // Light mode green
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Salaire ce mois', style: labelSmall),
              Text('${formatCurrency(monthlySalary)}', style: titleSmall),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Dépenses', style: labelSmall),
              Text('${formatCurrency(monthlyExpenses)}', style: titleSmall),
            ],
          ),
        ],
      ),
    ],
  ),
)
```

**Light Mode:** Overlay opacity 0.8, border `rgba(15,110,86,0.2)`  
**Dark Mode:** Overlay opacity 0.12, border `rgba(255,255,255,0.12)`

---

### Quick Action Buttons (2×2 Grid)

**Design Goal:** Fast access to main features, prominent CTA

```dart
GridView.count(
  crossAxisCount: 2,
  mainAxisSpacing: 12,
  crossAxisSpacing: 12,
  shrinkWrap: true,
  physics: NeverScrollableScrollPhysics(),
  children: [
    ActionButton(
      icon: Icons.add_circle,
      label: 'Ajouter',
      color: Color(0xFF0F6E56), // Primary green
      onTap: () => navigateToAddTransaction(),
    ),
    ActionButton(
      icon: Icons.trending_down,
      label: 'Dépense',
      color: Color(0xFF1D9E75), // Light green
      onTap: () => navigateToExpense(),
    ),
    ActionButton(
      icon: Icons.target,
      label: 'Objectif',
      color: Color(0xFF5DCAA5), // Accent green
      onTap: () => navigateToGoals(),
    ),
    ActionButton(
      icon: Icons.trending_up,
      label: 'Investir',
      color: Color(0xFFEF9F27), // Amber (warning color)
      onTap: () => navigateToInvest(),
    ),
  ],
)
```

**Button Specification:**
- Shape: Rounded square (borderRadius: 16)
- Height: 100dp
- Glassmorphic background (light 0.7, dark 0.08)
- Icon: 32px, centered
- Label: 12px, centered below icon
- Press animation: Scale 0.95 @ 150ms

---

### Stat Cards (Month Expenses + Savings)

**Side-by-side 50/50 split**

```dart
Row(
  children: [
    Expanded(
      child: GlassCard(
        blur: 15,
        opacity: 0.7, // Light mode
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dépenses du Mois', style: bodySmall),
                Icon(Icons.trending_down, size: 20, color: Colors.red),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '${formatCurrency(monthlyExpenses)}',
              style: titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              '${percentageOfSalary(monthlyExpenses, salary)}% du salaire',
              style: labelSmall,
            ),
          ],
        ),
      ),
    ),
    SizedBox(width: 12), // Spacing between cards
    Expanded(
      child: GlassCard(
        blur: 15,
        opacity: 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Épargne du Mois', style: bodySmall),
                Icon(Icons.savings, size: 20, color: Color(0xFF059669)),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '${formatCurrency(monthlySavings)}',
              style: titleMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              '${percentageOfSalary(monthlySavings, salary)}% du salaire',
              style: labelSmall,
            ),
          ],
        ),
      ),
    ),
  ],
)
```

---

### 50/30/20 Rule Bars (3 Progress Bars)

**Design Goal:** Show savings rule at a glance with clear progress

```dart
GlassCard(
  blur: 15,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Règle 50/30/20', style: titleSmall.copyWith(fontWeight: FontWeight.w600)),
      SizedBox(height: 16),
      
      // 50% Besoins
      ProgressBarSection(
        label: 'Besoins (50%)',
        percentage: percentageOfBudget(50),
        actual: actualNeeds,
        target: salary * 0.5,
        color: Color(0xFF0F6E56), // Primary green
      ),
      SizedBox(height: 12),
      
      // 30% Envies
      ProgressBarSection(
        label: 'Envies (30%)',
        percentage: percentageOfBudget(30),
        actual: actualWants,
        target: salary * 0.3,
        color: Color(0xFF1D9E75), // Light green
      ),
      SizedBox(height: 12),
      
      // 20% Épargne
      ProgressBarSection(
        label: 'Épargne (20%)',
        percentage: percentageOfBudget(20),
        actual: actualSavings,
        target: salary * 0.2,
        color: Color(0xFF5DCAA5), // Accent green
      ),
    ],
  ),
)
```

**ProgressBarSection Widget:**
```dart
Widget ProgressBarSection({
  required String label,
  required double percentage, // 0-100
  required double actual,
  required double target,
  required Color color,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: labelSmall),
          Text('${percentage.toStringAsFixed(0)}%', style: labelSmall.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
      SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: percentage / 100,
          minHeight: 8,
          backgroundColor: color.withOpacity(0.1),
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
      SizedBox(height: 4),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${formatCurrency(actual)} / ${formatCurrency(target)}', style: labelSmall.copyWith(color: textSecondary)),
        ],
      ),
    ],
  );
}
```

---

### Daily Lesson Card (Featured)

**Design Goal:** Encourage financial learning, green branded card

```dart
GlassCard(
  blur: 15,
  padding: EdgeInsets.all(16),
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF0F6E56).withOpacity(0.8),
          Color(0xFF1D9E75).withOpacity(0.6),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: Colors.white.withOpacity(0.2),
        width: 1,
      ),
    ),
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Leçon du Jour',
              style: labelSmall.copyWith(
                color: Colors.white.withOpacity(0.9),
                fontWeight: FontWeight.w600,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Débutant',
                style: labelSmall.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Text(
          lesson.title,
          style: titleSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          lesson.description,
          style: bodySmall.copyWith(
            color: Colors.white.withOpacity(0.85),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${lesson.duration}',
              style: labelSmall.copyWith(color: Colors.white.withOpacity(0.7)),
            ),
            Icon(Icons.arrow_forward, size: 16, color: Colors.white),
          ],
        ),
      ],
    ),
  ),
  onTap: () => navigateToLesson(lesson.id),
)
```

**Light Mode:** Gradient opacity 0.8–0.6  
**Dark Mode:** Same gradient (green is vibrant in dark mode)

---

## 🎭 THEME VARIANTS

### Light Mode Hero Section
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFF9FAFB), Color(0xFFFFFFFF)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ),
)
```

### Dark Mode Hero Section
```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFF0F172A), Color(0xFF1A2847)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  ),
)
```

---

## 📱 RESPONSIVE DESIGN

### Phone Layout (375px–430px)
- **Available Balance Card:** Full width, top-pinned
- **Quick Actions:** 2×2 grid, 12px gap
- **Stat Cards:** Full width, stacked vertically
- **Progress Bars:** Full width
- **Lesson Card:** Full width, bottom of scroll area

### Tablet Layout (768px+)
- **Sidebar Navigation:** Optional (use platform conventions)
- **Available Balance Card:** 60% width, left column
- **Quick Actions:** 2×2 grid, 16px gap, right sidebar (optional)
- **Stat Cards:** Side-by-side (50/50 split)
- **Progress Bars:** Max width 600px, centered

---

## 🎯 INTERACTION STATES

### Button Press Feedback
- Scale: 1.0 → 0.95 @ 150ms ease-out
- Opacity: 1.0 → 0.9 @ 150ms
- After release: Return to 1.0 @ 100ms ease-out

### Card Tap
- Scale: 1.0 → 0.98 @ 100ms
- Overlay opacity increases slightly (frosted glass strengthens)

### Pull-to-Refresh (Optional)
- Hero section slides down slightly
- Blur animation: 15px → 20px → 15px (3-frame shimmer)

---

## ✅ CHECKLIST FOR HOME SCREEN

- [ ] Greeting uses user's first name (from profile)
- [ ] Available balance = monthSalary - monthlyExpenses
- [ ] Quick action buttons route to correct screens
- [ ] Stat cards pull real data from database
- [ ] 50/30/20 bars calculate correctly from transactions
- [ ] Daily lesson card pulls from lessons database
- [ ] Dark mode tested separately (not inverted)
- [ ] Light mode contrast ≥4.5:1 on all text
- [ ] Dark mode contrast ≥4.5:1 on all text
- [ ] All cards have proper glassmorphic blur + border
- [ ] Safe area padding respected (status bar, notch)
- [ ] Bottom nav doesn't overlap content
- [ ] Scroll smooth and performant (no jank)
- [ ] Animations 150–300ms (never >400ms)

---

## 🚀 NEXT STEPS

1. **Create reusable GlassCard component** with configurable blur/opacity
2. **Build ActionButton component** with press animation
3. **Implement ProgressBarSection** for reuse across screens
4. **Connect to database** for real transaction data
5. **Test light/dark toggle** and verify contrast
6. **Test on small phone** (375px) and tablet (768px)

---

**Made with 💚 for Home Screen**
