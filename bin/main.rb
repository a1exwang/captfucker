require './dispatcher/process_list'
require './processors/all'

ProcessList.process './test_imgs/src/aca/from', from: :folder do |h|
  #h.add BinaryProcessor, mode: :gray_range, average_mode: :ntsc, gray_range: (35908.0/65536..35990.0/65536)
  h.add BinaryProcessor, mode: :gray_range, average_mode: :ntsc, gray_range: (0..35990.0/65536)
  h.add ColorDivider, mode: :filter, filter_min: 4
  h.add WeightProcessor, min_adjs: 4, direction: :thinner
  h.add CharCuter
  #h.add Normalizer, size: 50
  h.add FileSaver, path: './test_imgs/src/aca/to'
  h.add PictureFontIdentifyProcessor, path: '/fonts'
end
