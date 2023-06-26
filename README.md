# 🏞 FindHospital

## 🖥 프로젝트 소개
### **지도에서 내 주변 500m 내에 있는 병원의 위치와 거리를 확인 할 수있는 APP** 

- KakaoMap MapView에서 병원의 위치 확인
- 지도 아래 병원 리스트를 통해 병원의 위치, 거리 확인
- 내 위치를 지도 중심으로 이동하여 근처 병원 확인 가능
- 지도를 드래그 하여 다른 지역의 병원 확인 가능
- 병원 리트에서 해당 병원을 선택하면 지도에서 위치 확인 가능

<br>

## ⏱️ 개발 기간 및 사용 기술

- 개발 기간: 2023.06.13 ~ 2023.06.21 (1주)
- 사용 기술:  `UIKit`, `URLSession`, `RxSwift`, `RxCocoa`, `CoreLocation`, `MVVM`

<br>

## 📌 핵심 기술

- CoreLocation을 통한 사용자 위치정보 제공 권한 확인

- KakaoMap을 통한 지도 활용

- Reactive extension을 통해 원하는 기능 구현

- RxSwift를 이용한 네트워크 통신으로 데이터 불러오기

- RxCocoa를 이용한 이벤트 처리

<br>

## ✏️ Reactive에서 원하는 기능을 사용할 수 있도록 extension을 통해 구현
- UIKit에 구현된 기능을 Reactive에서 확장하여 사용
  -> UIViewController에서 에러메세지가 알람으로 띄워질 수 있도록 구현
  -> 지도에서 해당 병원을 선택하면 tableView에서 동일한 병원의 정보가 가장 위로 오도록 설정
  -> 지도에 redPin의 형태로 병원의 위치를 표현

```swift
extension Reactive where Base: HPInfoViewController {
    var presentAlert: Binder<String> {
        return Binder(base) { base, message in
            // ...
        }
    }

    var showSelectedLocation: Binder<Int> {
        return Binder(base) { base, row in
            // ...
        }
    }
    
    var addPOIItems: Binder<[MTMapPoint]> {
        return Binder(base) { base, point in
            // ...
        }
    }
}
```

<br>

## ✏️ RxSwift를 이용하여 네트워크 통신을 통해 Single의 형태로 데이터 반환
- rx의 data 메서드를 이용하여 불러온 json데이터를 디코딩 하여 사용가능한 데이터로 반환

```swift
func getLocation(by mapPoint: MTMapPoint) -> Single<Result<LocationData, URLError>> {
        // ...
        
        return session.rx.data(request: request as URLRequest)
            .map { data in
                do {
                    let decoder = JSONDecoder()
                    let locationData = try decoder.decode(LocationData.self, from: data)
                    return .success(locationData)
                } catch {
                    return .failure(URLError(.cannotParseResponse))
                }
            }
            .catch({ _ in
                return .just(.failure(URLError(.cannotLoadFromNetwork)))
            })
            .asSingle()
    }
```

- ViewModel에서 지도 중심점을 전달해줄 때 마다 네트워크 통신을 통해 데이터를 불러옴

```swift
class HPInfoViewModel {
      // ...
      
      let HPLocationDataResult = mapCenterPoint
          .flatMapLatest(model.getLocation)
          .share()

      // ...
}
```

- 불러온 데이터를 cellData로 변환한 뒤 tableViewCell에 전달하여 표현

```swift
class HPInfoViewModel {
      // ...
      
      let HPLocationDataValue = HPLocationDataResult
            .compactMap { result -> LocationData? in
                guard case let .success(value) = result else {
                    return nil
                }
                return value
            }

      HPLocationDataValue
            .map { data in
                return data.documents
            }
            .bind(to: documentData)
            .disposed(by: disposeBag)

      detailListCellData = documentData
            .map(model.documentToCellData(_:))
            .asDriver(onErrorDriveWith: .empty())

      // ...
}

class HPInfoViewController: UIViewController {
      // ...

      func bind(_ viewModel: HPInfoViewModel) {
            // ...
            
            viewModel.detailListCellData
            .drive(detailList.rx.items) { tv, row, data in
                guard let cell = tv.dequeueReusableCell(withIdentifier: "DetailListCell", for: IndexPath(row: row, section: 0)) as? DetailListCell else { return UITableViewCell() }
                
                cell.setData(data)
                return cell
            }
            .disposed(by: disposeBag)

            // ...
      }

      // ...
}
```

<br>

## 📱 UI
