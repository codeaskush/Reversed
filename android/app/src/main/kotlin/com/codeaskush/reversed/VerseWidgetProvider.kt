package com.codeaskush.reversed

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import android.graphics.Color
import android.net.Uri
import android.util.TypedValue
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * Home-screen widget showing the verse of the day.
 *
 * All data is written by the Flutter side through the `home_widget` plugin
 * (see `lib/services/widget_sync.dart`). The Flutter side stores a schedule
 * of upcoming days so the widget can roll over at midnight without the app
 * being opened; this provider picks the entry for today's date.
 */
class VerseWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val verse = VerseStore.today(widgetData)
        val style = WidgetStyle.from(widgetData)

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.verse_widget).apply {
                // Colour filter ignores alpha, so translucent styles (Glass) set the
                // image alpha separately.
                setInt(R.id.widget_background, "setColorFilter", style.background or 0xFF000000.toInt())
                setInt(R.id.widget_background, "setImageAlpha", Color.alpha(style.background))
                setInt(R.id.widget_icon, "setColorFilter", style.accent)
                setTextColor(R.id.widget_label, style.accent)
                setTextColor(R.id.widget_reference, style.foreground)
                setTextColor(R.id.widget_text, style.foreground)
                setInt(R.id.widget_shuffle, "setColorFilter", style.accent)

                setTextViewText(R.id.widget_reference, verse.displayReference)
                setTextViewText(R.id.widget_text, verse.text)
                setTextViewTextSize(R.id.widget_reference, TypedValue.COMPLEX_UNIT_SP, 15f * style.textScale)
                setTextViewTextSize(R.id.widget_text, TypedValue.COMPLEX_UNIT_SP, 15f * style.textScale)

                // Tapping the verse opens the app.
                setOnClickPendingIntent(
                    R.id.widget_root,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
                // Tapping the shuffle icon runs Dart code in the background.
                setOnClickPendingIntent(
                    R.id.widget_shuffle,
                    HomeWidgetBackgroundIntent.getBroadcast(context, Uri.parse("reversed://next")),
                )
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        // Re-render when the date changes so the schedule rolls over promptly.
        when (intent.action) {
            Intent.ACTION_DATE_CHANGED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> refreshAll(context)
        }
    }

    private fun refreshAll(context: Context) {
        val manager = AppWidgetManager.getInstance(context)
        val ids = manager.getAppWidgetIds(ComponentName(context, VerseWidgetProvider::class.java))
        if (ids.isNotEmpty()) {
            onUpdate(context, manager, ids, HomeWidgetPlugin.getData(context))
        }
    }
}

/** A verse as stored by the Flutter side. */
data class WidgetVerse(val source: String, val reference: String, val text: String) {
    /** e.g. "Bhagavad Gita 2.47" or "Bible John 3:16". */
    val displayReference: String
        get() = listOf(source, reference).filter { it.isNotBlank() }.joinToString(" ")
}

object VerseStore {
    private const val KEY_TEXT = "verse_text"
    private const val KEY_REFERENCE = "verse_reference"
    private const val KEY_SOURCE = "verse_source"
    private const val KEY_SCHEDULE = "verse_schedule"

    private val placeholder = WidgetVerse(
        source = "Reversed",
        reference = "",
        text = "Open the app once to choose your scripture and see today's verse.",
    )

    /** The verse for today's local date, falling back to the last pushed verse. */
    fun today(data: SharedPreferences): WidgetVerse {
        val todayKey = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        fromSchedule(data.getString(KEY_SCHEDULE, null), todayKey)?.let { return it }

        val text = data.getString(KEY_TEXT, null) ?: return placeholder
        return WidgetVerse(
            source = data.getString(KEY_SOURCE, null) ?: "",
            reference = data.getString(KEY_REFERENCE, null) ?: "",
            text = text,
        )
    }

    private fun fromSchedule(json: String?, dayKey: String): WidgetVerse? {
        if (json.isNullOrEmpty()) return null
        return try {
            val array = JSONArray(json)
            for (i in 0 until array.length()) {
                val entry = array.getJSONObject(i)
                if (entry.optString("date") == dayKey) {
                    return WidgetVerse(
                        source = entry.optString("source"),
                        reference = entry.optString("reference"),
                        text = entry.optString("text"),
                    )
                }
            }
            null
        } catch (_: Exception) {
            null
        }
    }
}

/** Colours and sizing chosen in the app's settings. */
data class WidgetStyle(
    val background: Int,
    val foreground: Int,
    val accent: Int,
    val textScale: Float,
) {
    companion object {
        fun from(data: SharedPreferences) = WidgetStyle(
            background = color(data.getString("widget_bg", null), 0xFFE07A1F.toInt()),
            foreground = color(data.getString("widget_fg", null), Color.WHITE),
            accent = color(data.getString("widget_accent", null), 0xD9FFFFFF.toInt()),
            textScale = data.getString("widget_text_scale", null)?.toFloatOrNull() ?: 1f,
        )

        private fun color(hex: String?, fallback: Int): Int =
            hex?.let { runCatching { Color.parseColor(it) }.getOrNull() } ?: fallback
    }
}
