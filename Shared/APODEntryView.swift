//
//  APODEntryView.swift
//  APODShared
//
//  Created by Jacob Bandes-Storch on 9/23/20.
//

import SwiftUI
import struct WidgetKit.WidgetPreviewContext

extension DateFormatter {
  static let monthDay = with(DateFormatter()) {
    $0.setLocalizedDateFormatFromTemplate("MMM dd")
  }
}

struct PhotoView: View {
  let date: Date
  let image: AnyView?
  let caption: String?
  let copyright: String?

  var body: some View {
    ZStack {
      Color.black.edgesIgnoringSafeArea(.all)
        .ifLet(image) {
          $0.overlay($1)
        }

      HStack {
        VStack(alignment: .leading, spacing: 4) {
          HStack {
            Spacer()
            Text(date, formatter: DateFormatter.monthDay)
              .font(.caption2)
          }
          Spacer()
          if let caption = caption {
            Text(caption).font(.system(.footnote)).bold().lineSpacing(-4)
          }
          if let copyright = copyright {
            Text(copyright).font(.system(.caption2))
          }
        }
        Spacer()
      }
      .padding(EdgeInsets(top: 14, leading: 16, bottom: 12, trailing: 10))
      .foregroundColor(Color(.sRGB, white: 0.9))
      .shadow(color: .black, radius: 2, x: 0.0, y: 0.0)
    }
  }
}

public struct APODEntryView: View {
  let entry: Loading<Result<APODEntry, Error>>

  public init(entry: Loading<Result<APODEntry, Error>>) {
    self.entry = entry
  }

  public init(entry: APODEntry) {
    self.entry = .loaded(.success(entry))
  }

  public var body: some View {
    switch entry {
    case .notLoading:
      Group {}

    case .loading:
      Color.black
        .overlay(ProgressView())
        .colorScheme(.dark)

    case .loaded(.failure(let error)):
      Group {}

    case .loaded(.success(let entry)):
      if let image = entry.loadImage() {
        PhotoView(
          date: entry.date.asDate()!,
          image: AnyView(Image(uiImage: image).resizable().aspectRatio(contentMode: .fill)),
          caption: entry.title,
          copyright: entry.copyright)
      } else {
        ZStack {
          Color.black.edgesIgnoringSafeArea(.all)
          VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
              .font(.system(size: 64, weight: .ultraLight))
            Text("Couldn‘t load image")
              .font(.footnote)
          }.foregroundColor(.gray)
        }
      }
    }
  }
}

struct APODEntryView_Previews: PreviewProvider {
  static var previews: some View {
    let previewJSON = """
{
  "copyright": "Adam Block",
  "date": "2020-09-25",
  "explanation": "The Great Spiral Galaxy in Andromeda (also known as M31), a mere 2.5 million light-years distant, is the closest large spiral to our own Milky Way. Andromeda is visible to the unaided eye as a small, faint, fuzzy patch, but because its surface brightness is so low, casual skygazers can't appreciate the galaxy's impressive extent in planet Earth's sky. This entertaining composite image compares the angular size of the nearby galaxy to a brighter, more familiar celestial sight. In it, a deep exposure of Andromeda, tracing beautiful blue star clusters in spiral arms far beyond the bright yellow core, is combined with a typical view of a nearly full Moon. Shown at the same angular scale, the Moon covers about 1/2 degree on the sky, while the galaxy is clearly several times that size. The deep Andromeda exposure also includes two bright satellite galaxies, M32 and M110 (below and right).",
  "hdurl": "https://apod.nasa.gov/apod/image/2009/m31abtpmoon.jpg",
  "media_type": "image",
  "service_version": "v1",
  "title": "Moon over Andromeda",
  "url": "https://apod.nasa.gov/apod/image/2009/m31abtpmoon1024.jpg"
}
""".data(using: .utf8)!

    APODEntryView(
      entry: with(try! JSONDecoder().decode(APODEntry.self, from: previewJSON)) {
        $0.PREVIEW_overrideImage = #imageLiteral(resourceName: "sampleImage")
      })
      .previewContext(WidgetPreviewContext(family: .systemSmall))

    APODEntryView(
      entry: with(try! JSONDecoder().decode(APODEntry.self, from: previewJSON)) {
        $0.PREVIEW_overrideImage = #imageLiteral(resourceName: "sampleImage")
      })
      .previewContext(WidgetPreviewContext(family: .systemMedium))

    PhotoView(date: Date(), image: AnyView(Image(uiImage: #imageLiteral(resourceName: "sampleImage")).resizable().aspectRatio(3, contentMode: .fill)), caption: "Hello", copyright: "There")
      .previewContext(WidgetPreviewContext(family: .systemMedium))

    PhotoView(date: Date(), image: AnyView(Image(uiImage: #imageLiteral(resourceName: "sampleImage")).resizable().aspectRatio(0.3, contentMode: .fill)), caption: "Hello", copyright: "There")
      .previewContext(WidgetPreviewContext(family: .systemMedium))

    APODEntryView(
      entry: try! JSONDecoder().decode(APODEntry.self, from: previewJSON))
      .previewContext(WidgetPreviewContext(family: .systemMedium))

    APODEntryView(
      entry: (try! JSONDecoder().decode(APODEntry.self, from: previewJSON)))
      .redacted(reason: .placeholder)
      .previewContext(WidgetPreviewContext(family: .systemMedium))

    APODEntryView(
      entry: .notLoading)
      .redacted(reason: .placeholder)
      .previewLayout(.fixed(width: 200, height: 200))

    APODEntryView(
      entry: .loading)
      .redacted(reason: .placeholder)
      .previewLayout(.fixed(width: 200, height: 200))

    APODEntryView(
      entry: .loaded(.failure(URLError(.badServerResponse))))
      .redacted(reason: .placeholder)
      .previewLayout(.fixed(width: 200, height: 200))
  }
}
